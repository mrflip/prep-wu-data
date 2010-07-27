#!/usr/bin/env ruby

#
# For every object x that exists in [unspliced, old_objects] merge and uniq into new_objects
#
unspliced     = ARGV[0]
old_objects   = ARGV[1]
new_objects   = ARGV[2]

def construct_paths object, unspliced, old_objects, new_objects
  new_object_dir      = File.join(unspliced, object)
  existing_object_dir = File.join(old_objects, object)
  return unless system %Q{hadoop fs -test -e #{new_object_dir}}
  if system %Q{hadoop fs -test -e #{existing_object_dir}}
    inputdirs  = [new_object_dir, existing_object_dir].join(",")
  else
    inputdirs  = new_object_dir
  end
  outputdir  = File.join(new_objects, object)
  [inputdirs, outputdir]
end

%w[ twitter_user_partial twitter_user twitter_user_profile twitter_user_location twitter_user_style twitter_user_id ].each do |object|
  paths = construct_paths object, unspliced, old_objects, new_objects
  next unless paths
  system %Q{#{File.dirname(__FILE__)}/last_seen_state.rb --rm --run #{paths.first} #{paths.last}; true }
end

%w[ a_follows_b a_favorites_b a_atsigns_b a_retweets_b a_replies_b hashtag smiley tweet_url stock_token word_token geo tweet delete_tweet tweet-noid twitter_user_search_id tweet-no-reply-id].each do |object|
  paths = construct_paths object, unspliced, old_objects, new_objects
  next unless paths
  system %Q{hdp-stream #{paths.first} #{paths.last} `which cat` `which uniq` 2 3 -jobconf mapred.map.tasks.speculative.execution=false; true}
end
