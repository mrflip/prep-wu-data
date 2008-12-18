#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'imw' ; include IMW
include FileUtils
as_dset __FILE__

# Get the password -- keep this file .gitignore'd obvs.
require File.dirname(__FILE__)+'/twitter_pass.rb'
IMW.log.level = Logger::INFO

require 'imw/chunk_store/scrape'
require 'twitter_graph_model'


USERNAMES_FILE = 'fixd/dump/user_names_by_followers_count.tsv'
# USERNAMES_FILE = '/tmp/foo_users.tsv'
exists, not_exists, lines = [0,0,0]
SKIP_LINES = 45000
File.open(USERNAMES_FILE).each do |line|
  line.chomp!; lines += 1
  next if lines < SKIP_LINES
  screen_name, *rest = line.split(/\t/); next unless screen_name
  [:followers ].each do |context|
    track_count(:fetches, 1000)
    scrape_file = TwitterScrapeFile.new(screen_name, context, 1)
    if scrape_file.exists? then exists += 1  else  not_exists += 1 end
    puts "Exists\t#{exists}\tNot Exists\t#{not_exists}" if (exists % 4000 == 0)
    success = scrape_file.wget :http_user => TWITTER_USERNAME, :http_passwd => TWITTER_PASSWD,
      :sleep_time => 0, :log_level => Logger::DEBUG
    warn "No yuo on #{screen_name}: #{scrape_file.result_status}" unless success
  end
end
puts "Exists\t#{exists}\tNot Exists\t#{not_exists}"


