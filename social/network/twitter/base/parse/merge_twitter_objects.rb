#!/usr/bin/env ruby

require 'rubygems'
require 'rake'
require 'swineherd' ; include Swineherd
require 'swineherd/script/pig_script' ; include Swineherd::Script
require 'swineherd/script/wukong_script'

Settings.define :ics_tw_scripts, :default => "/home/jacob/Programming/infochimps-data/social/network/twitter"
Settings.resolve!

## immutable objects, FIXME.
def define_merge_tasks objects
  objects.each do |object, reduce_tasks|
    task object do
      sources     = ["/tmp/streamed/#{object}", "/tmp/unspliced/#{object}"]
      destination = "/tmp/objects/#{object}"
      HDFS.merge(sources, destination, {:reduce_tasks => reduce_tasks, :partion_fields => 3, :sort_fields => 3})
    end
  end
end

immutable_objects = {
  :tweet        => 60,
  :delete_tweet => 4,
  :geo          => 6,
  :stock_token  => 6,
  :smiley       => 10,
  :hashtag      => 20,
  :tweet_url    => 40
}

define_merge_tasks immutable_objects
multitask :merge_immutable => immutable_objects.keys
##


## mutable objects
def last_seen_state_tasks objects
  objects.each do |object|
    task object do
      uniqer = WukongScript.new("#{Settings.ics_tw_scripts}/base/parse/last_seen_state.rb")
      uniqer.output << "/tmp/objects/#{object}"
      uniqer.input  << "/tmp/streamed/#{object}"
      uniqer.input  << "/tmp/unspliced/#{object}"
      uniqer.run
      uniqer.refresh!
    end
  end  
end

# user objects are mutable
mutable_objects = %w[twitter_user twitter_user_profile twitter_user_style]

# generate a set of tasks, one for each object
last_seen_state_tasks mutable_objects

# task defined to them all
task :merge_mutable => mutable_objects
##

#
# Either run 'merge_immutable' or 'merge_mutable'
#
Rake::MultiTask[ARGV[0]].invoke
