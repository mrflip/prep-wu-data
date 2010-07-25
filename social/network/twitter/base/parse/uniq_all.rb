#!/usr/bin/env ruby

#
# Takes in a directory containing unspliced objects that contains
# duplicate records. De-dupes immutable objects such as tweets in the
# usual way and uniqs mutable records (user records) by last seen state.
# Objects are written to the objects dir.
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

%w[ twitter_user_partial twitter_user twitter_user_profile twitter_user_location twitter_user_style ].each do |object|
  paths = construct_paths object, unspliced, old_objects, new_objects
  next unless paths
  system %Q{#{File.dirname(__FILE__)}/last_seen_state.rb --rm --run #{paths.first} #{paths.last}; true }
end

%w[ a_follows_b a_favorites_b geo tweet delete_tweet tweet-noid twitter_user_search_id ].each do |object|
  paths = construct_paths object, unspliced, old_objects, new_objects
  next unless paths
  system %Q{hdp-stream #{paths.first} #{paths.last} `which cat` `which uniq` 2 3 -jobconf mapred.map.tasks.speculative.execution=false; true}
end
