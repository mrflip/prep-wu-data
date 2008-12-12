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
    timeless = ripd_file.gsub(/\+\d+-\d+.json/, '*')
    matches = Dir[timeless]
    if ! matches.empty?
      ts = matches.last.gsub(/.*\+(\d{8})-(\d{6})(?:\.\w{0,7})?\z/, '\1\2')
      self.cached_uri.timestamp = DateTime.parse ts
      # puts "%s\t%s\t%-120s\t%s" % [ts, matches.last, self.cached_uri.timestamp, timeless[40..-1], ripd_file[50..-1]]
    end
    ! matches.empty?
  end
  def ripd_file
    File.join RIPD_ROOT, file_path
  end
end

#
# Flat list of usernames (in first column)
#
USERNAMES_FILE = 'fixd/dump/scrape_requests_followers_20081212.tsv'
File.open(USERNAMES_FILE).readlines.each do |line|
  line.chomp!
  screen_name, context, page, *_ = line.split(/\t/); next unless screen_name && context && page
  track_count(:fetches, 1000)
  #
  # find file
  #
  scrape_file = TwitterScrapeFile.new(screen_name, context, page)
  scrape_file.exists?
  success = scrape_file.wget :http_user => TWITTER_USERNAME, :http_passwd => TWITTER_PASSWD,
    :sleep_time => 0, :log_level => Logger::DEBUG
  warn "No yuo on #{screen_name} #{context} #{page}: #{scrape_file.result_status}" unless success
end

# SELECT screen_name,
#       REPLACE(context, 'scrape_', '') AS context,
#       page, id, priority
#     FROM scrape_requests
#     WHERE     scraped_at IS NULL AND result_code IS NULL AND context = 'scrape_user'
#     ORDER BY page ASC, priority ASC
# INTO OUTFILE '/data/fixd/social/network/twitter_friends/dump/scrape_requests_user_20081212.tsv'
