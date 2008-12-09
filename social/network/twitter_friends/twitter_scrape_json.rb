#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'imw' ; include IMW
require 'imw/extract/html_parser'
require 'imw/dataset/datamapper'
as_dset __FILE__
require 'fileutils'; include FileUtils

#
require 'twitter_profile_model'
require File.dirname(__FILE__)+'/twitter_pass.rb'

# #
# # Setup database
# #
# DataMapper::Logger.new(STDERR, :debug) # watch SQL log -- must be BEFORE call to db setup
dbparams = IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_twitter_friends' })
DataMapper.setup_remote_connection dbparams

SLEEP_BETWEEN_WGETS = 0 # .2 # about 1-2/s

# -- assets stored as :ripd, com/tw/com.twitter/mr/mrflip-#uuid-#timestamp
# scraper
# * iterates over URLs
# * pulls in chunks sorted according to a priority
#
# tracker
# * fills url request pool
# * scrape - parse
#
#
# cached_uri_store
# * turns uri into file path
# * returns cached file if within time window
#

#
# wget url_to_get, ripd_file, sleep_time
#
# Crudely scrape a url
#
# get the url
# leave a 0-byte turd on failure to prevent re-fetching; use find ripd/ -size 0 --exec rm {} \; to scrub
# sleeps for sleep_time
#
def wget rip_url, ripd_file, sleep_time=1
  cd path_to(:ripd_root) do
    mkdir_p   File.dirname(ripd_file)
    if File.exists?(ripd_file)
      puts "Skipping #{rip_url}"
    else
      print `wget -nv --timeout=8 --http-user=#{TWITTER_USERNAME} --http-passwd=#{TWITTER_PASSWD} -O'#{ripd_file}' '#{rip_url}' `
      # puts "(sleeping #{sleep_time})" ;
      sleep sleep_time
    end
    success = File.exists?(ripd_file) && (File.size(ripd_file) != 0)
    return success
  end
end

def ripd_file_from_url url
  case
  when m = %r{http://twitter.com/([^/]+/[^/]+)/(..?)([^?]*?)\?page=(.*)}.match(url)
    resource, prefix, suffix, page = m.captures
    "_com/_tw/com.twitter/#{resource}/_#{prefix.downcase}/#{prefix}#{suffix}%3Fpage%3D#{page}"
  when m = %r{http://twitter.com/([^/]+/[^/]+)/(..?)([^?]*?)$}.match(url)
    resource, prefix, suffix = m.captures
    "_com/_tw/com.twitter/#{resource}/_#{prefix.downcase}/#{prefix}#{suffix}"
  else
    raise "Can't grok url #{url}"
  end
end

def scrape_pass min_priority, max_priority, hard_limit = nil
  hard_limit ||= 5*(max_priority-min_priority)
  [
    # 'friends',
    'followers',
    # 'info',
  ].each do |context|
    announce("Scraping  %s %6d..%-6d popular+unrequested users" % [context, min_priority, max_priority])
    popular_and_neglected = AssetRequest.all :scraped_time => nil, :user_resource => context,
    :priority.gte => min_priority, :priority.lt => max_priority, # :page.lt => 20,
    :fields => [:uri, :id],
    :order  => [:page.asc, :priority.asc],
    :limit  => hard_limit
    popular_and_neglected.each do |req|
      track_count    :users, 50
      ripd_file = ripd_file_from_url(req.uri)
      next unless ripd_file =~ %r{^_com/_tw}
      success = wget req.uri, ripd_file, SLEEP_BETWEEN_WGETS
      # mark columns
      req.result_code  = success
      req.scraped_time = Time.now.utc
      req.save
    end
    announce "Finished %s chunk %6d..%-6d" % [context, min_priority, max_priority]
  end
end


n_requests = AssetRequest.count(:user_resource => ['friends', 'followers'], :scraped_time => nil)
chunksize = 200
offset    = 0   # for parallel runs, space each separate job by 1/n of the problem space
chunks    = (n_requests / chunksize).to_i + 1
(1..chunks).each do |chunk|
  min_priority = (chunk-1)*chunksize + offset
  scrape_pass min_priority, min_priority+chunksize
end
