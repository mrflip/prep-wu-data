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
    when :followers, :flwr_parse then twitter_user.followers_count ? (twitter_user.followers_count/100.0).ceil : 0
    when :friends,   :frnd_parse then twitter_user.following_count ? (twitter_user.following_count/100.0).ceil : 0
    end
  end
  #
  # # http://twitter.com/statuses/followers/infochimps.json?page=1&since=Tue%2C+27+Mar+2007+22%3A55%3A48+GMT
  # # http://twitter.com/statuses/friends/infochimps.json?page=1
  # # http://twitter.com/users/show/infochimps.json
  # # http://twitter.com/account/rate_limit_status/infochimps.json
  def self.insert_user_requests twitter_user
    priority     = twitter_user.twitter_page_rank ? twitter_user.twitter_page_rank.prestige : (100_000 - twitter_user.followers_count)
    [:info_parse, :flwr_parse, :frnd_parse].map do |context|
      pages = pages_from_info(twitter_user, context) or next

      #
      #
      (1..pages).map do |page|
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


def request_pass threshold, offset = 0
  announce("Inserting requests %6d..%-6d for popular+unrequested users" % [offset, threshold+offset])
  popular_and_neglected = TwitterUser.all :followers_count.not => nil, # :parsed => true,
     :fields => [:id, :twitter_name, :following_count, :followers_count, :updates_count, :parsed, :failed],
     :order  => [:followers_count.desc],
     :limit  => threshold, :offset => offset
  popular_and_neglected.each do |twitter_user|
    track_count    :users, 50
    TwitterAssetRequester.bulk_dump_user_requests twitter_user
  end
  announce "Finished chunk %6d..%-6d" % [offset, threshold+offset]
end


n_requests = TwitterUser.count(:parsed => true)
chunksize = 5000
offset    = 0   # for parallel runs, space each separate job by a few chunksizes.
chunks    = (n_requests / chunksize).to_i + 1
(0..chunks).each do |chunk|
  request_pass chunksize, offset + chunk*chunksize
end
