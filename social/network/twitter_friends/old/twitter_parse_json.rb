#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'json'
require 'imw' ; include IMW
require 'imw/extract/html_parser'
require 'imw/dataset/datamapper'
require 'imw/tracker'
require 'imw/transform'
require 'twitter_profile_model'
as_dset __FILE__

# #
# # Setup database
# #

# DataMapper::Logger.new(STDOUT, :debug) # watch SQL log -- must be BEFORE call to db setup
dbparams = IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_twitter_friends' })
DataMapper.setup_remote_connection dbparams

USER_REMAPPING =   {
  :twitter_name                    => :screen_name,
  :real_name                       => :name,
  :native_id                       => :id,
  :location                        => :location,
  :web                             => :url,
  :bio                             => :description,
  :followers_count                 => :followers_count,
  :profile_img_url                 => :profile_image_url,
  :protected                       => :protected,
}
USER_REMAPPING.each{|k,v| USER_REMAPPING[k] = v.to_s}
TWEET_REMAPPING = {
  :id                            => :id,
  :content                       => :text,
  :datetime                      => :created_at,
  :inreplyto_name                => :in_reply_to_user_id,
  :inreplyto_tweet_id            => :in_reply_to_status_id,
  # nil                          => :truncated,
  # nil                          => :favorited,
}
TWEET_REMAPPING.each{|k,v| TWEET_REMAPPING[k] = v.to_s}

require 'twitter_autourl'
$atsigns_transformer   = RegexpRepeatedTransformer.new(:content, RE_ATSIGNS)
$hashtags_transformer  = RegexpRepeatedTransformer.new(:content, RE_HASHTAGS)
$tweeturls_transformer = RegexpRepeatedTransformer.new(:content, RE_URL)
def remap mapping, src
  hsh = { }
  mapping.each{|attr, src_attr| hsh[attr] = src[src_attr] }
  hsh.compact
end
def parse_twitter_followers twitter_user, ripd_file, flwr_bare_users_file, flwr_tweets_file, flwr_friendships_file
  begin
    raw_followers = JSON.load(File.open(ripd_file))
  rescue Exception => e
    warn "Couldn't open and parse #{ripd_file}: #{e}"
    return false
  end
  raw_followers.each do |raw|
    follower_hsh = remap(USER_REMAPPING, raw)
    # follower        = TwitterUser.first  :twitter_name => follower_hsh[:twitter_name], :fields => [:id]
    # if !follower then follower = TwitterUser.create :twitter_name => follower_hsh[:twitter_name] end
    # next unless follower

    # Update friend
    flwr_bare_users_file << follower_hsh.values_at(
      :twitter_name, :real_name, :native_id, :location, :web, :bio, :followers_count, :profile_img_url, :protected)

    # Update friendship
    # Friendship.find_or_create(:friend_id => twitter_user.id, :follower_id => follower.id)
    flwr_friendships_file << [twitter_user.native_id, follower_hsh[:native_id]]

    if raw_tweet = raw['status']
      tweet_hsh = remap(TWEET_REMAPPING, raw_tweet)
      tweet_hsh[:id] = tweet_hsh[:id].to_i
      tweet_hsh[:all_atsigns]             = $atsigns_transformer.transform(tweet_hsh).to_json
      tweet_hsh[:all_hash_tags]           = $hashtags_transformer.transform(tweet_hsh).to_json
      tweet_hsh[:all_tweeted_urls]        = $tweeturls_transformer.transform(tweet_hsh).to_json
      fromsource_raw = raw_tweet['source']
      if ! fromsource_raw.blank?
        if m = %r{<a href="([^\"]+)">([^<]+)</a>}.match(fromsource_raw)
          tweet_hsh[:fromsource_url], tweet_hsh[:fromsource] = m.captures
        else
          tweet_hsh[:fromsource] = fromsource_raw
        end
      end
      tweet_hsh[:datetime]        = DateTime.parse(tweet_hsh[:datetime]) if tweet_hsh[:datetime]
      tweet_hsh[:twitter_user_id] = follower.native_id
      # tweet = Tweet.update_or_create({ :id => tweet_hsh[:id] }, tweet_hsh.compact)

      flwr_tweets_file << tweet_hsh.values_at(:id, :content, :datetime, :inreplyto_name, :inreplyto_tweet_id)
    end
  end
  true
end

def fixd_file(context, resource, batch)
  "fixd/#{context}_parsed/#{resource}-#{batch}.tsv"
end

batch = '' # Time.now.strftime('%Y%m%d-%H%M%S')
flwr_bare_users_file, flwr_tweets_file, flwr_friendships_file =
  [:flwr_bare_users, :flwr_tweets, :flwr_friendships].map do |dump_file_type|
  FasterCSV.open(fixd_file(:followers, batch, dump_file_type), "w")
end
tracker = Tracker.new AssetRequest, 5, :shard => 0, :dry_run => true
tracker.each(:flwr_parse, { :fields => [:id, :twitter_name, :page], :priority.gt => 10000, :priority.lt => 10010 }) do |req|
  $stderr.print "%d-%-18s"%[req.priority, req.twitter_name]
  # load user
  twitter_user = TwitterUser.first( :twitter_name => req.twitter_name, :fields => [:id, :twitter_name] ) or next
  # do it
  success = parse_twitter_followers twitter_user, '/data/ripd/'+req.ripd_file, flwr_bare_users_file, flwr_tweets_file, flwr_friendships_file
end
