#!/usr/bin/env ruby

require 'rubygems'
require 'swineherd' ; include Swineherd
require 'infochimps-data/twitter_stream.rake'

Settings.define :base_input_dir,     :default => "s3n://monkeyshines.infochimps.org/data/ripd/com.tw"
Settings.define :wuclan_twitter_dir, :default => "/home/travis/wuclan/lib/wuclan/twitter"
Settings.define :unsplicer,          :default => "/home/travis/hadoop-unsplicer/bin/unsplice"
Settings.define :start_date,         :default => "201010"
Settings.resolve!

task :parse_twitter_api do
  script         = WukongScript.new("#{Settings.wuclan_twitter_dir}/parse/parse_twitter_api_requests-v2.rb"))
  script.input  << "#{Settings.base_input_dir}/com.twitter/#{Settings.start_date}\*"
  script.output << "/tmp/parsed/api"
end

task :parse_twitter_stream do
  script         = WukongScript.new(File.join(Settings.wuclan_twitter_dir, "parse_twitter_stream_requests-v2.rb"))
  script.input  << File.join(Settings.base_input_dir, "com.twitter.stream")
  script.output << "/tmp/parsed/stream"
end

#task :parse_twitter_search do
#  script         = WukongScript.new(File.join(Settings.wuclan_twitter_dir, "parse_twitter_search_requests.rb"))
#  script.input  << File.join(Settings.base_input_dir, "com.twitter.search")
#  script.output << "/tmp/parsed/search"
#end

task :unsplice_twitter => [:parse_twitter_api, :parse_twitter_stream, :parse_twitter_search] do
  script         = CrazyBashScriptyThing.new(File.join(Settings.hadoop_unsplicer_dir, "unsplice"))
  script.options = "max_map_attempts, blah, blah, someshit, whatevs"
  script.input  << "/tmp/parsed"
  script.output << "/tmp/unspliced"
end

task :create_user_id_table => [:unsplice_twitter] do

end

task :rectify_a_atsigns_b => [:create_user_id_table] do
end

task :fix_tweet_noids => [:create_user_id_table] do
end

task :merge_immutable => [:rectify_a_atsigns_b, :fix_tweet_noids] do
end

task :merge_mutable => [:unsplice_twitter] do
end






