#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'imw' ; include IMW
require 'imw/extract/html_parser'
require 'imw/dataset/datamapper'
require 'twitter_profile_model'
as_dset __FILE__
require 'fileutils'; include FileUtils
# #
# # Setup database
# #

# DataMapper::Logger.new(STDOUT, :debug) # watch SQL log -- must be BEFORE call to db setup
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

# user - username - html_profile
class AssetRequest
  include DataMapper::Resource
  property :uri,                String, :length => 1024, :unique_index => true
  property :priority,           Integer
  property :result_code,        Integer
  property :scraped_time,       DateTime
  # connect to twitter model
  property :id,                 Integer, :serial => true
  property :twitter_user_id,    Integer
  property :user_resource,      String, :length => 15 # public_page, info, followers, followings, tweets, favorites
  property :page,               Integer

  def self.request(uri, priority)
    req = self.find_or_create({ :uri =>  uri })
    req.priority = [req.priority, priority].min
    req if req.save
  end
end
AssetRequest.auto_upgrade!


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
    puts ripd_file
    mkdir_p   File.dirname(ripd_file)
    if File.exists?(ripd_file) then puts "Skipping #{rip_url}" ; return end
    print `wget -nv --http-user=mrflip --http-passwd= -O'#{ripd_file}' '#{rip_url}' `
    success = File.exists?(ripd_file) && (File.size(ripd_file) != 0)
    FileUtils.touch        ripd_file  # leave a 0-byte turd so we don't refresh
    sleep sleep_time
    return success
  end
end

def ripd_file_from_url url
  url.gsub(%r{http://twitter.com/(statuses/[^/]+)/(..?)([^?]*?)\?page=(.*)}, '_com/_tw/com.twitter/\1/_\2/\2\3%3Fpage%3D\4')
end

def scrape_pass threshold, offset = 0
  announce("Scraping %6d..%-6d for popular+unrequested users" % [offset, threshold+offset])
  popular_and_neglected = AssetRequest.all :scraped_time => nil,
     :fields => [:uri, :id],
     :order  => [:priority.asc],
     :limit  => threshold, :offset => offset
  popular_and_neglected.each do |req|
    track_count    :users, 50
    success = wget req.uri, ripd_file_from_url(req.uri), 1
    # mark columns
    req.result_code  = success
    req.scraped_time = Time.now.utc if success
    req.save
  end
  announce "Finished chunk %6d..%-6d" % [offset, threshold+offset]
end


n_requests = AssetRequest.count(:scraped_time => nil)
chunksize = 100
chunks    = (n_requests / chunksize).to_i + 1
(0..chunks).each do |chunk|
  scrape_pass chunksize, chunk * chunksize
end

# class TwitterAssetRequester
#   #
#   #
#   #
#   def self.url_from_info twitter_username, user_resource, page
#     url_base            = 'http://twitter.com'
#     case user_resource
#     when :public_page   then "#{url_base}/#{twitter_username}"
#     when :info          then "#{url_base}/users/show/#{twitter_username}.json"
#     when :followers     then "#{url_base}/statuses/followers/#{twitter_username}.json?page=#{page}"
#     when :friends       then "#{url_base}/statuses/friends/#{twitter_username}.json?page=#{page}"
#     end
#   end
#   def self.pages_from_info twitter_user, user_resource
#     case user_resource
#     when :public_page   then 1
#     when :info          then 1
#     when :followers     then 1 + (twitter_user.followers.length)/100
#     when :friends       then 1 + (twitter_user.friends.length  )/100
#     end
#   end
#   #
#   # # http://twitter.com/statuses/followers/infochimps.json?page=1&since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT
#   # # http://twitter.com/statuses/friends/infochimps.json?page=1
#   # # http://twitter.com/users/show/infochimps.json
#   # # http://twitter.com/account/rate_limit_status/infochimps.json
#   def self.request_user_resource twitter_user_id, user_resource, priority
#     twitter_user = TwitterUser.first(twitter_user_id)
#     priority     = TwitterUser.followers.length
#     (1..pages_from_info(twitter_user, user_resource)).map do |page|
#       url = url_from_info twitter_user.twitter_username, user_resource, page
#       TwitterAssetRequest.request(uri, twitter_user.id, user_resource, page, priority)
#     end
#   end
# end
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
