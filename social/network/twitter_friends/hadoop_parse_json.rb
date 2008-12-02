#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'json'
require 'faster_csv' 
require 'imw' ; include IMW
require 'imw/transform'
require 'twitter_autourl'
require 'hadoop_utils'; include HadoopUtils
# as_dset __FILE__

#
# Field order for dump files
#
FIELDS = {
  :user_partial => %w[ id             screen_name                followers_count               protected  name url location description  profile_image_url],
  :user         => %w[ id  created_at screen_name statuses_count followers_count friends_count protected ],
  :user_profile => %w[ id  name url location description time_zone utc_offset ],
  :user_style   => %w[ id   profile_background_color profile_text_color profile_link_color profile_sidebar_border_color profile_sidebar_fill_color profile_background_image_url profile_image_url profile_background_tile ],
  #:user_metric => %w[ id  replied_to_count tweeturls_count hashtags_count prestige pagerank twoosh_count ],
  :afollowsb    => %w[ rel user_a user_b ],
  :arepliedb    => %w[ rel user_a user_b  status_id reply_status_id ],
  :aatsigndb    => %w[ rel user_a user_b  status_id ],
  :hashtag      => %w[ rel user_a hashtag status_id ],
  :url          => %w[ rel user_a url     status_id ],
  :tweet        => %w[ id created_at twitter_user_id text favorited truncated tweet_len in_reply_to_user_id in_reply_to_status_id fromsource fromsource_url all_atsigns all_hash_tags all_tweeted_urls ]                        
}
DATEFORMAT = "%Y%m%d%H%M%S"

             
UserPartial  = Struct.new( :id,  :screen_name, :followers_count, :protected, :name, :url, :location, :description, :profile_image_url )
User         = Struct.new( :id,  :created_at, :screen_name, :statuses_count, :followers_count, :friends_count, :protected )
UserProfile  = Struct.new( :id,  :name, :url, :location, :description, :time_zone, :utc_offset )
UserStyle    = Struct.new( :id,  :profile_background_color, :profile_text_color, :profile_link_color, :profile_sidebar_border_color, :profile_sidebar_fill_color, :profile_background_image_url, :profile_image_url, :profile_background_tile )
UserMetric   = Struct.new( :id,  :replied_to_count, :tweeturls_count, :hashtags_count, :prestige, :pagerank, :twoosh_count )
AFollowsB    = Struct.new( :rel, :user_a, :user_b )
ARepliedB    = Struct.new( :rel, :user_a, :user_b, :status_id, :reply_status_id )
AAtsignsB    = Struct.new( :rel, :user_a, :user_b, :status_id )
Hashtag      = Struct.new( :rel, :user_a, :hashtag, :status_id )
TweetUrl     = Struct.new( :rel, :user_a, :url, :status_id )
Tweet        = Struct.new( :id,  :created_at, :twitter_user_id, :text, :favorited, :truncated, :tweet_len, :in_reply_to_user_id, :in_reply_to_status_id, :fromsource, :fromsource_url, :all_atsigns, :all_hash_tags, :all_tweeted_urls )

[ UserPartial User UserProfile UserStyle UserMetric AFollowsB ARepliedB AAtsignsB Hashtag TweetUrl Tweet ].each do |klass|
  klass.send(:include, HadoopStruct)
end

# transform and emit User
# 
def emit_user user_hsh, timestamp, origin, is_partial
  user_hsh['protected']  = user_hsh['protected'] ? 1 : 0
  user_hsh['timestamp_'] = timestamp
  scrub user_hsh, :name, :location, :description
  if is_partial
    u = UserPartial.new(timestamp, origin)
  end
  resources.each do |resource|
    emit resource, user_hsh['screen_name'], timestamp, user_hsh 
  end
end


# ===========================================================================
#
# Transform tweet
#
$atsigns_transformer   = RegexpRepeatedTransformer.new('text', RE_ATSIGNS)
$hashtags_transformer  = RegexpRepeatedTransformer.new('text', RE_HASHTAGS)
$tweeturls_transformer = RegexpRepeatedTransformer.new('text', RE_URL)
def emit_tweet tweet_hsh, timestamp, origin
  #
  scrub tweet_hsh, :text
  tweet_hsh['all_atsigns']             = $atsigns_transformer.transform(  tweet_hsh).to_json
  tweet_hsh['all_hash_tags']           = $hashtags_transformer.transform( tweet_hsh).to_json
  tweet_hsh['all_tweeted_urls']        = $tweeturls_transformer.transform(tweet_hsh).to_json
  fromsource_raw = tweet_hsh['source']
  if ! fromsource_raw.blank?
    if m = %r{<a href="([^\"]+)">([^<]+)</a>}.match(fromsource_raw)
      tweet_hsh['fromsource_url'], tweet_hsh['fromsource'] = m.captures
    else
      tweet_hsh['fromsource'] = fromsource_raw
    end
  end
  tweet_hsh['created_at']  = DateTime.parse(tweet_hsh['created_at']).strftime(DATEFORMAT) if tweet_hsh['created_at']
  tweet_hsh['favorited'] = tweet_hsh['favorited'] ? 1 : 0
  tweet_hsh['truncated'] = tweet_hsh['truncated'] ? 1 : 0
  tweet_hsh['tweet_len'] = tweet_hsh['text'].length
  #
  # Emit
  #
  timestamp       = tweet_hsh['created_at']  # Tweets are immutable
  status_id       = tweet_hsh['id']
  twitter_user_id = tweet_hsh['twitter_user_id']
  if tweet_hsh['in_reply_to_user_id'] then 
    at = tweet_hsh['in_reply_to_user_id']
    emit :arepliedb, twitter_user_id, timestamp, 'rel' => 'aatsignsb', 'user_a' => twitter_user_id, 'user_b' => at,  'status_id' => status_id, 'reply_status_id' => tweet_hsh['in_reply_to_status_id'] 
  end
  tweet_hsh['all_atsigns'     ].each{|at| emit :aatsignsb, twitter_user_id, timestamp, 'rel' => 'aatsignsb', 'user_a' => twitter_user_id, 'user_b'  => at, 'status_id' => status_id }
  tweet_hsh['all_tweeted_urls'].each{|at| emit :url,       twitter_user_id, timestamp, 'rel' => 'url',       'user_a' => twitter_user_id, 'url'     => at, 'status_id' => status_id }
  tweet_hsh['all_hash_tags'   ].each{|at| emit :hashtag,   twitter_user_id, timestamp, 'rel' => 'hashtag',   'user_a' => twitter_user_id, 'hashtag' => at, 'status_id' => status_id }
  # 
  emit :tweet, "%011d"%[tweet_hsh['id']], timestamp, tweet_hsh
end


#
#
def load_line line
  m = %r{^(\w+)-(\w+)-(\d+)-(\d{14})\t(.*)$}.match(line) 
  if !m then warn "Can't grok #{line}"; return [] ; end
  resource, screen_name, page, timestamp, json = m.captures
  begin
    raw = JSON.load(json)
  rescue Exception => e
    warn "Couldn't open and parse #{[resource, screen_name, page, timestamp].join('-')}: #{e}"
    return []
  end
  origin = [resource, screen_name, page, timestamp].join('-')
  [ resource, screen_name, page, timestamp, origin, raw ]
end

# ===========================================================================
#
# parse each line in STDIN
#
$stdin.each do |line|
  line.chomp! ; next if line.blank?
  resource, screen_name, page, timestamp, origin, raw = load_line(line); next if raw.blank?
  track_count screen_name[0..1].downcase, 100
  # $stderr.puts("parsing %-15s\t%-31s\t%7d\t%s" % [resource, screen_name, page, timestamp])
  case resource
  when 'raw_followers', 'raw_friends'
    raw.each do |hsh|
      next if hsh.blank? || (! hsh.is_a?(Hash))
      #
      # user
      emit_user hsh, timestamp, origin, :user_partial
      #
      # follower or friend
      if resource == 'raw_followers' then follower, friend = [ hsh['screen_name'], screen_name ]
      else                                follower, friend = [ screen_name,        hsh['screen_name'] ] ; end
      emit :afollowsb, follower, timestamp, origin, 'user_a' => follower, 'user_b' => friend
      #
      # tweet
      tweet_hsh  = hsh['status'] or next
      tweet_hsh['twitter_user_id'] = hsh['id']
      emit_tweet tweet_hsh, timestamp, origin
    end
  when 'raw_userinfo'
    emit_user raw, timestamp, origin, :user, :user_profile, :user_style
  else
    raise "Crap bubbles -- unexpected resource #{resource}"
  end
end

# ===========================================================================
#
# afollowsb     time  1 0 0 0 0 0 0   user_a_id       user_b_id
# afavoredb     time  0 1 0 0 0 0 0   user_a_id       user_b_id
# arepliedb     time  0 0 1 0 0 0 0   user_a_id       user_b_id       status_id
# aatsigndb     time  0 0 0 1 0 0 0   user_a_id       user_b_id       status_id
#
# hashtag       time  0 0 0 0 1 0 0   user_a_id                       status_id       sha1(hashtag)
# url           time  0 0 0 0 0 1 0   user_a_id                       status_id       sha1(url)
# word          time  0 0 0 0 0 0 1   user_a_id                                       sha1(word)
