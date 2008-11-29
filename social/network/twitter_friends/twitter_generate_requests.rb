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

# DataMapper::Logger.new(STDERR, :debug) # watch SQL log -- must be BEFORE call to db setup
dbparams = IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_twitter_friends' })
DataMapper.setup_remote_connection dbparams


class TwitterAssetRequester
  #
  #
  #
  def self.url_from_info twitter_user, context, page=1
    url_base            = 'http://twitter.com'
    name                = twitter_user.twitter_name
    case context
    when :public_page            then "#{url_base}/#{name}"
    when :info,      :info_parse then "#{url_base}/users/show/#{name}.json"
    when :followers, :flwr_parse then "#{url_base}/statuses/followers/#{name}.json?page=#{page}"
    when :friends,   :frnd_parse then "#{url_base}/statuses/friends/#{name}.json?page=#{page}"
    end
  end
  def self.pages_from_info twitter_user, context
    case context
    when :public_page   then 1
    when :info,      :info_parse then 1
    when :followers, :flwr_parse then ((twitter_user.followers_count||1)/100.0).ceil
    when :friends,   :frnd_parse then ((twitter_user.following_count||1)/100.0).ceil
    end
  end
  #
  # # http://twitter.com/statuses/followers/infochimps.json?page=1&since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT
  # # http://twitter.com/statuses/friends/infochimps.json?page=1
  # # http://twitter.com/users/show/infochimps.json
  # # http://twitter.com/account/rate_limit_status/infochimps.json
  def self.insert_user_requests twitter_user
    priority     = twitter_user.twitter_page_rank ? twitter_user.twitter_page_rank.prestige : (500_000 - 1000*(twitter_user.followers_count||0))
    [:info, :followers, :friends, :info_parse, :flwr_parse, :frnd_parse].map do |context|
      pages = pages_from_info(twitter_user, context) or next

      #
      #
      (1..pages).map do |page|
        track_count    :pages, 1000
        url = url_from_info twitter_user, context, page
        # AssetRequest.update_or_create({
        #     :twitter_user_id => twitter_user.id,
        #     :user_resource   => context,
        #     :page            => page
        #   }, {
        #     :uri             => url,
        #     :priority        => priority,
        #     :twitter_name    => twitter_user.twitter_name,
        #   })
        "(#{twitter_user.id}, '#{context}', #{page}, '#{url}', #{priority}, '#{twitter_user.twitter_name}')"
      end
    end.flatten
  end

  INSERT_QUERY_BASE = "INSERT DELAYED IGNORE INTO `asset_requests` (`twitter_user_id`, `user_resource`, `page`, `uri`, `priority`, `twitter_name`) VALUES"
  def self.bulk_dump_user_requests twitter_user
    strs = insert_user_requests(twitter_user)
    return if strs.blank?
    puts INSERT_QUERY_BASE
    puts strs.join(",\n  ")
    puts ";"
  end
end

# SELECT * FROM TASK WHERE ID BETWEEN N AND N+99999 is much better choice
# hen doing a bulk insert/update/change to a MySQL table you can temporarily disable index updates like this:
# ALTER TABLE $tbl_name DISABLE KEYS
# ... do stuff ...
# ALTER TABLE $tbl_name ENABLE KEYS


#
# requests are queued
# then requests are processed
#

def request_pass limit, offset = 0
  announce("Inserting requests %6d..%-6d for popular+unrequested users" % [offset, limit+offset])
  popular_and_neglected = TwitterUser.all({ # :followers_count.not => nil,
     :fields => [:id, :twitter_name, :following_count, :followers_count],  # , :updates_count, :parsed, :failed],
     # :order  => [:followers_count.asc],
     :limit  => limit, :offset => offset })
  popular_and_neglected.each do |twitter_user|
    track_count    :users, 100
    TwitterAssetRequester.bulk_dump_user_requests twitter_user
  end
  announce "Finished chunk %6d..%-6d" % [offset, limit+offset]
end


chunksize = 5000
offset    = 400_000   # for parallel runs, space each separate job by a few chunksizes.
n_requests = TwitterUser.count - offset
chunks    = (n_requests / chunksize).to_i + 1
(1..chunks).each do |chunk|
  request_pass chunksize, offset + (chunk-1)*chunksize
end
