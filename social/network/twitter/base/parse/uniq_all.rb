#!/usr/bin/env ruby

#
# Takes in a directory containing unspliced objects that contains
# duplicate records. De-dupes immutable objects such as tweets in the
# usual way and uniqs mutable records (user records) by last seen state.
# Objects are written to the objects dir.
#
unspliced = ARGV[0]
objects   = ARGV[1]

%w[ twitter_user twitter_user_partial twitter_user_profile twitter_user_location twitter_user_style ].each do |object|
  inputdir  = File.join(unspliced, object)
  outputdir = File.join(objects, object)
  system %Q{echo ./last_seen_state.rb --rm --run #{inputdir} #{outputdir} }
end

%w[ a_follows_b geo delete_tweet tweet-noid twitter_user_search_id ].each do |object|
  inputdir  = File.join(unspliced, object)
  outputdir = File.join(objects, object)
  system %Q{echo hdp-stream #{inputdir} #{outputdir} `which cat` `which uniq` 2 3 -jobconf mapred.map.tasks.speculative.execution=false}
end
