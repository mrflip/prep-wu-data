#!/usr/bin/env ruby

#
# Add new objects to these if we serialize out new ones
#
IMMUTABLE_OBJECTS = %w[a_follows_b a_favorites_b a_atsigns_b a_retweets_b a_replies_b hashtag smiley tweet_url stock_token word_token geo tweet delete_tweet tweet-noid twitter_user_search_id tweet-no-reply-id]
MUTABLE_OBJECTS   = %w[twitter_user_partial twitter_user twitter_user_profile twitter_user_location twitter_user_style twitter_user_id]


class MergeTwitterObjects
  # full hdfs paths to newly unspliced objects, existing objects,
  #  and where new output objects should live
  attr_accessor :unspliced, :prior_objects, :new_objects
  
  def initialize *args
    return unless args.length == 3
    @unspliced, @prior_objects, @new_objects = args
  end

  #
  # Watch out.
  #
  def merge!
    merge_mutable
    merge_immutable
  end

  #
  # Merge immutable objects by simply doing a uniq of all inputs
  #
  def merge_immutable
    IMMUTABLE_OBJECTS.each do |object|
      hdfspaths = input_and_output_paths object # hdfspaths.first = input, hdfspaths.last = output
      next if hdfspaths.empty?
      success = system %Q{hdp-stream #{hdfspaths.first} #{hdfspaths.last} `which cat` `which uniq` 2 3}
      remove_inputs(hdfspaths.first) if success
    end
  end

  def merge_mutable
    MUTABLE_OBJECTS.each do |object|
      hdfspaths = input_and_output_paths object # hdfspaths.first = input, hdfspaths.last = output
      next if hdfspaths.empty?
      success = system %Q{#{File.dirname(__FILE__)}/last_seen_state.rb --run #{hdfspaths.first} #{hdfspaths.last}}
      remove_inputs(hdfspaths.first) if success
    end
  end

  #
  # Construct full hdfs paths to where the object is
  # and will end up. Only paths that actually exist
  # will be returned as inputs.
  #
  def input_and_output_paths object
    unspliced_dir = File.join(unspliced, object)
    prior_dir     = File.join(prior_objects, object)
    inputdirs     = []
    inputdirs << unspliced_dir if hdfspath_exists? unspliced_dir
    inputdirs << prior_dir     if hdfspath_exists? prior_dir
    inputdirs = inputdirs.join(",")
    return [] if inputdirs.empty?
    outputdir  = File.join(new_objects, object)
    [inputdirs, outputdir]
  end


  def hdfspath_exists? path
    system %Q{hadoop fs -test -e #{path}}
  end

  #
  # This is necessary because some of the object dirs are quite
  # large, ie we cannot afford to double the size of the data for now
  #
  def remove_inputs inputs
    hdfspaths = inputs.split(",")
    hdfspaths.each do |path|
      system %Q{hdp-rm -r -skipTrash #{path}}
    end
  end

end

raise "\n\nUsage: ruby uniq_all.rb /path/to/unspliced_objects /path/to/prior_objects /path/to/output_objects\n" unless ARGV.length == 3
merge_manager = MergeTwitterObjects.new(ARGV[0], ARGV[1], ARGV[2])
merge_manager.merge!
