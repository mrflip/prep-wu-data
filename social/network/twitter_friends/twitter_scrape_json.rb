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
      print `wget -nv --http-user=#{TWITTER_USERNAME} --http-passwd=#{TWITTER_PASSWD} -O'#{ripd_file}' '#{rip_url}' `
      FileUtils.touch        ripd_file  # leave a 0-byte turd so we don't refresh
      # puts "(sleeping #{sleep_time})" ;
      sleep sleep_time
    end
    success = File.exists?(ripd_file) && (File.size(ripd_file) != 0)
    return success
  end
end

def ripd_file_from_url url
  m = %r{http://twitter.com/([^/]+/[^/]+)/(..?)([^?]*?)\?page=(.*)}.match(url) or raise "Can't grok url #{url}"
  resource, prefix, suffix, page = m.captures
  "_com/_tw/com.twitter/#{resource}/_#{prefix.downcase}/#{prefix}#{suffix}%3Fpage%3D#{page}"
end

def scrape_pass threshold, offset = 0
  announce("Scraping %6d..%-6d for popular+unrequested users" % [offset, threshold+offset])
  popular_and_neglected = AssetRequest.all :scraped_time => nil, :user_resource => 'followers', # :result_code => nil,
     :fields => [:uri, :id],
     :order  => [:priority.asc],
     :limit  => threshold, :offset => offset
  popular_and_neglected.each do |req|
    track_count    :users, 50
    ripd_file = ripd_file_from_url(req.uri)
    next unless ripd_file =~ %r{^_com/_tw}
    success = wget req.uri, ripd_file, 0.2
    # mark columns
    req.result_code  = success
    req.scraped_time = Time.now.utc
    req.save
  end
  announce "Finished chunk %6d..%-6d" % [offset, threshold+offset]
end


n_requests = AssetRequest.count(:scraped_time => nil)
chunksize = 1000
offset    = 0   # for parallel runs, space each separate job by a few chunksizes.
chunks    = (n_requests / chunksize).to_i + 1
(0..chunks).each do |chunk|
  scrape_pass chunksize, offset
end
#
#
# class TwitterScrapeTracker
# end
#
# #
# # A scraper connects an
# # * an AssetRequest list
# # * an AssetStore
# # * a  ScrapeTracker
# #
# #  -- grab a chunk of unfetched uris, highest-priority first
# #  -- fetch them into the asset store
# #
# class TwitterScraper
#   attr_accessor :twitter_scrape_tracker
#   attr_accessor :request_chunk_size
#   attr_accessor :scraper_options
#
#   def initialize(scraper_options)
#     self.scraper_options = scraper_options
#   end
#
#   def scrape()
#     # ask request_list for a chunk of unfetched uris, high-priority first
#
#     # make the asset_store pull them in.
#
#     # note the result in our request_list
#
#   end
# end
#
#
# #
# # friends
# #
# # Returns up to 100 of given id's friends who have most recently updated, each
# # with current status inline.
# #  URL: http://twitter.com/statuses/friends/id.format
# # Formats: xml, json
# # Method(s): GET
# # Parameters:
# #     * page.   Optional.
# #       Retrieves the next 100 friends.  Ex:
# #       http://twitter.com/statuses/friends.xml?page=2
# #     * since.  Optional.
# #       Narrows the returned results to just those friendships created after the
# #       specified HTTP-formatted date, up to 24 hours old.  The same behavior is
# #       available by setting an If-Modified-Since header in your HTTP request.
# #       Ex:  http://twitter.com/statuses/friends.xml?since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT
# #
# # show
# #
# # Returns extended information of a given user, specified by ID or screen name
# # as per the required id parameter below.  This information includes design
# # settings, so third party developers can theme their widgets according to a
# # given user's preferences. You must be properly authenticated to request the
# # page of a protected user.
# #
# #   URL: http://twitter.com/users/show/id.format
# #
# # Formats: xml, json
# # Method(s): GET
# # Parameters: One of the following is required:
# #     * id.
# #       The ID or screen name of a user.  Ex:
# #       http://twitter.com/users/show/12345.json or
# #       http://twitter.com/users/show/bob.xml
# #     * email.
# #       May be used in place of "id" parameter above.  The email address of a
# #       user.  May be used in place of Ex:
# #       http://twitter.com/users/show.xml?email=test@example.com
# #