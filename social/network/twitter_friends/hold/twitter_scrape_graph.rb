#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'imw' ; include IMW
require 'imw/dataset/datamapper'
include FileUtils
as_dset __FILE__

# Get the password -- keep this file .gitignore'd obvs.
require File.dirname(__FILE__)+'/twitter_pass.rb'
IMW.log.level = Logger::INFO

require 'imw/chunk_store/scrape'
require 'twitter_graph_model'
require 'twitter_scrape_model'
require 'twitter_scrape_store'


#
# Setup database
#
# DataMapper.logging = true
# DataMapper.setup_remote_connection( IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_twitter_graph' }) )
RIPD_ROOT = path_to(:ripd_root)

TwitterScrapeFile.class_eval do
  def exists?
    false
  end
  def ripd_file
    File.join RIPD_ROOT, file_path
  end
end

#
# Flat list of usernames (in first column)
#
#
# USERNAMES_FILE = 'rawd/scrape_requests/scrape_request-followers-20081227_a'
USERNAMES_FILE = 'fixd/dump/india_ids.tsv'
File.open(USERNAMES_FILE) do |f|
  i = 0
  f.each do |line|
    line.chomp!
    id, screen_name, *_ = line.split(/\t/);
    context = 'timeline'; page=1; count=200
    screen_name = id
    i += 1; $stderr.puts "%s\t%7i\t%s"%[Time.now, i, screen_name] if (i % 10000 == 0)
    #
    # find file
    #
    scrape_file = TwitterScrapeFile.new(screen_name, id, context, page, count)
    scrape_file.exists?
    success = scrape_file.wget :http_user => TWITTER_USERNAME, :http_passwd => TWITTER_PASSWD,
      :sleep_time => 0.5, :log_level => Logger::DEBUG
    # warn "No yuo on #{screen_name} #{context} #{page}: #{scrape_file.result_status}" unless success
  end
end
