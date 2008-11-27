#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'json'
require 'imw' ; include IMW
require 'imw/extract/html_parser'
require 'imw/dataset/datamapper'
require 'twitter_profile_model'
as_dset __FILE__

# #
# # Setup database
# #

# DataMapper::Logger.new(STDOUT, :debug) # watch SQL log -- must be BEFORE call to db setup
dbparams = IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_twitter_friends' })
DataMapper.setup_remote_connection dbparams




# # matches color defs in the user style's css snippets
# COLOR_RE = 'color\:\s*.([\da-f]+)'
# 
# def natural_merge dest, raw, only=nil
#   raw = raw.slice(*only) if only
#   # raw.each{|k,v| dest[k] = v if v }
#   dest.attributes = raw.compact #
# end

# def parse_twitter_user twitter_user, profile_page_filename
#   return if (!twitter_user) || twitter_user.parsed || twitter_user.failed
#   return unless File.exist?(profile_page_filename)
#   File.open(profile_page_filename) do |profile_page_file|
#     # begin
#     #   doc = Hpricot(profile_page_file)
#     # rescue
#     #   twitter_user.parsed = false; twitter_user.failed = true; twitter_user.save
#     #   return
#     # end
#     # raw = $parser.parse(doc)
#     # twitter_user.last_scraped_date = File.mtime(profile_page_file)
#     # natural_merge twitter_user, raw, [:native_id, :profile_img_url]
#     # natural_merge twitter_user, raw[:profile]
#     # natural_merge twitter_user, raw[:stats]
#     # [:style_link_color, :style_text_color, :style_name_color, :style_bg_color, :style_sidebar_fill_color, :style_sidebar_border_color].each do |attr|
#     #   raw[:style_settings][attr] = raw[:style_settings][attr].hex if raw[:style_settings][attr]
#     # end
#     # raw[:style_settings][:style_bg_img_tile] = !!(raw[:style_settings][:style_bg_img_tile] =~ /no-repeat/)
#     # natural_merge twitter_user, raw[:style_settings]
#     # raw[:friends].each do |hsh|
#     #   next unless hsh[:twitter_name]
#     #   friend = TwitterUser.update_or_create({ :twitter_name => hsh[:twitter_name] }, { :mini_img_url => hsh[:mini_img_url]})
#     #   Friendship.find_or_create(:friend_id => friend.id, :follower_id => twitter_user.id)
#     # end
#     # raw[:tweets].each do |raw_tweet|
#     #   tweet_id_str = raw_tweet.delete(:tweet_id) or next
#     #   tweet_id = tweet_id_str.to_i
#     #   raise "Bad tweet id in #{twitter_name}: #{tweet_id_str.inspect} - #{raw_tweet.inspect}" unless (tweet_id && (tweet_id > 0))
#     #   [:all_atsigns, :all_hash_tags, :all_tweeted_urls].each do |attr| raw_tweet[attr] = raw_tweet[attr].to_json if raw_tweet[attr] end
#     #   raw_tweet[:inreplyto_tweet_id] = raw_tweet[:inreplyto_tweet_id].to_i if raw_tweet[:inreplyto_tweet_id]
#     #   tweet = Tweet.update_or_create({ :id => tweet_id }, raw_tweet.merge({ :twitter_user_id => twitter_user.id }))
#     #   # natural_merge tweet,
#     #   # tweet.save
#     #   twitter_user.tweets << tweet
#     # end
#     # # first_tweet = twitter_user.tweets.first(:order => [:datetime.asc])
#     # # last_tweet  = twitter_user.tweets.first(:order => [:datetime.desc])
#     # # twitter_user.first_seen_update_time = first_tweet.datetime if first_tweet
#     # # twitter_user.last_seen_update_time  = last_tweet.datetime  if last_tweet
#     # twitter_user.parsed = true
#     # twitter_user.save
#     # # puts raw.to_yaml
#   end
#   return true
# end



USER_REMAPPING =   { 
  :twitter_name                    => :screen_name,
  :real_name                       => :name,
  :native_id                       => :id,
  :location                        => :location,
  :web                             => :url,
  :bio                             => :description,
  :followers_count                 => :followers_count, 
  :profile_img_url                 => :profile_image_url,
  # nil                            => :protected,
}
USER_REMAPPING.each{|k,v| USER_REMAPPING[k] = v.to_s}
TWEET_REMAPPING = { 
  :id                            => :id,
  :content                       => :text,
  :datetime                      => :created_at,
  :inreplyto_name                => :in_reply_to_user_id,
  :inreplyto_tweet_id            => :in_reply_to_status_id,
  # nil                            => :truncated,
  # nil                            => :favorited,
}
TWEET_REMAPPING.each{|k,v| TWEET_REMAPPING[k] = v.to_s}

class Transformer
  attr_accessor :attribute
  attr_accessor :transformer
  def initialize attribute, matcher=nil
    self.attribute = attribute
    self.transformer  = transformer
  end
end
class RegexpRepeatedTransformer < Transformer
  attr_accessor :re
  def initialize attribute, re, transformer=nil
    super attribute, transformer
    self.re = re
  end
  def transform hsh
    raw = hsh[attribute] or return
    # get all matches
    val = raw.to_s.scan(re)
    # if there's only one capture group, flatten the array
    val = val.flatten if val.first && val.first.length == 1
    # pass to transformer, if any
    transformer ? transformer.transform(val) : val
  end
end

require 'twitter_autourl'
$atsigns_transformer   = RegexpRepeatedTransformer.new(:content, RE_ATSIGNS)
$hashtags_transformer  = RegexpRepeatedTransformer.new(:content, RE_HASHTAGS)
$tweeturls_transformer = RegexpRepeatedTransformer.new(:content, RE_URL)
def remap mapping, src
  hsh = { }
  mapping.each{|attr, src_attr| hsh[attr] = src[src_attr] }
  hsh.compact
end
def parse_twitter_followers twitter_user, ripd_file
  begin
    raw_followers = JSON.load(File.open(ripd_file))
  rescue Exception => e
    warn "Couldn't open and parse #{ripd_file}: #{e}"
    return false
  end
  raw_followers.each do |raw|
    user_hsh = remap(USER_REMAPPING, raw)
    follower = TwitterUser.update_or_create({ :twitter_name => user_hsh[:twitter_name] }, user_hsh)
    follower.save
    Friendship.find_or_create(:friend_id => twitter_user.id, :follower_id => follower.id)
    # puts [user_hsh].to_yaml
    
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
      tweet_hsh[:datetime] = DateTime.parse(tweet_hsh[:datetime]) if tweet_hsh[:datetime]
      tweet_hsh[:twitter_user_id] = follower.id
      tweet = Tweet.update_or_create({ :id => tweet_hsh[:id] }, tweet_hsh.compact)
      # puts [tweet_hsh, raw['status']['source']].to_yaml
    end    
  end
  true
end

def parse_pass threshold, offset = 0
  announce("Parsing %6d..%-6d popular but unparsed users" % [offset, threshold+offset])
  popular_and_neglected = AssetRequest.all :scraped_time => nil, :user_resource => 'flwr_parse', # :result_code => nil,
     :fields => [:twitter_name, :id, :page],
     :order  => [:priority.asc],
     :limit  => threshold, :offset => offset
  popular_and_neglected.each do |req|
    # log
    track_count    :users, 10;    
    $stderr.print "%-20s"%["#{req.twitter_name} (#{req.page})"]
    # load user
    twitter_user = TwitterUser.first( :twitter_name => req.twitter_name ) or next
    # do it
    success = parse_twitter_followers twitter_user, '/data/ripd/'+req.ripd_file
    # # mark columns
    req.result_code  = success
    req.scraped_time = Time.now.utc
    req.save
  end
  announce "Finished chunk %6d..%-6d" % [offset, threshold+offset]
end

# $parser = TwitterHTMLParser.new()
n_requests = AssetRequest.count(:scraped_time => nil, :user_resource => 'flwr_parse')
chunksize = 1000
offset    = 0
chunks    = (n_requests / chunksize).to_i + 1
(0..chunks).each do |chunk|
  parse_pass chunksize, offset
end

