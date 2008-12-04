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

DATEFORMAT = "%Y%m%d%H%M%S"
UserPartial  = HadoopStruct.new( '01',  :id,  :screen_name, :followers_count, :protected, :name, :url, :location, :description, :profile_image_url )
User         = HadoopStruct.new( '02',  :id,  :screen_name, :created_at, :statuses_count, :followers_count, :friends_count, :protected )
UserProfile  = HadoopStruct.new( '03',  :id,  :name, :url, :location, :description, :time_zone, :utc_offset )
UserStyle    = HadoopStruct.new( '04',  :id,  :profile_background_color, :profile_text_color, :profile_link_color, :profile_sidebar_border_color, :profile_sidebar_fill_color, :profile_background_image_url, :profile_image_url, :profile_background_tile )
AFollowsB    = HadoopStruct.new( '05',  :user_a_id, :user_a, :user_b )
BFollowsA    = HadoopStruct.new( '06',  :user_a_id, :user_a, :user_b )
ARepliedB    = HadoopStruct.new( '07',  :user_a_id, :user_b_id,       :status_id, :reply_status_id )
AAtsignsB    = HadoopStruct.new( '08',  :user_a_id, :user_a, :user_b, :status_id )
Hashtag      = HadoopStruct.new( '09',  :user_a_id, :hashtag,         :status_id )
TweetUrl     = HadoopStruct.new( '10',  :user_a_id, :tweet_url,       :status_id )
Tweet        = HadoopStruct.new( '11', :id,  :created_at, :twitter_user_id, :text, :favorited, :truncated, :tweet_len, :in_reply_to_user_id, :in_reply_to_status_id, :fromsource, :fromsource_url, :all_atsigns, :all_hash_tags, :all_tweeted_urls )
# UserMetric   = HadoopStruct.new( :id,  :replied_to_count, :tweeturls_count, :hashtags_count, :prestige, :pagerank, :twoosh_count )

# transform and emit User
#
def emit_user hsh, timestamp, is_partial
  hsh['protected']  = hsh['protected'] ? 1 : 0
  hsh['created_at']  = DateTime.parse(hsh['created_at']).strftime(DATEFORMAT) if hsh['created_at']
  scrub hsh, :name, :location, :description, :url
  if is_partial
    UserPartial.new(timestamp, hsh).emit( hsh['screen_name'] )
  else
    User.new(timestamp, hsh).emit( hsh['screen_name'] )
    UserProfile.new(timestamp, hsh).emit( hsh['screen_name'] )
    UserStyle.new(timestamp, hsh).emit( hsh['screen_name'] )
  end
end


# ===========================================================================
#
# Transform tweet
#

ATSIGNS_TRANSFORMER   = RegexpRepeatedTransformer.new('text', RE_ATSIGNS)
HASHTAGS_TRANSFORMER  = RegexpRepeatedTransformer.new('text', RE_HASHTAGS)
TWEETURLS_TRANSFORMER = RegexpRepeatedTransformer.new('text', RE_URL)
def emit_tweet tweet_hsh, timestamp
  #
  scrub tweet_hsh, :text
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
  timestamp       = tweet_hsh['created_at']     # Tweets are immutable
  status_id       = tweet_hsh['id']
  twitter_user    = tweet_hsh['twitter_user']
  twitter_user_id = tweet_hsh['twitter_user_id']
  owner_id        = twitter_user                # emit using twitter_user as key so all group together.
  #
  if tweet_hsh['in_reply_to_user_id'] then
    at = "%012d"%tweet_hsh['in_reply_to_user_id']
    reply = ARepliedB.new timestamp, 'id' => twitter_user_id,
      'user_a_id' => twitter_user_id, 'user_b' => at,  'status_id' => status_id, 'reply_status_id' => tweet_hsh['in_reply_to_status_id']
    reply.emit(twitter_user)
  end
  all_atsigns = ATSIGNS_TRANSFORMER.transform(  tweet_hsh)
  tweet_hsh['all_atsigns'] =  all_atsigns.to_json
  all_atsigns.each do |at|
    atsign = AAtsignsB.new timestamp, 'user_a_id' => twitter_user_id, 'user_a' => twitter_user,
      'user_b'  => at, 'status_id' => status_id
    atsign.emit at
  end
  all_tweeted_urls = TWEETURLS_TRANSFORMER.transform(tweet_hsh)
  tweet_hsh['all_tweeted_urls'] = all_tweeted_urls.to_json
  all_tweeted_urls.each do |at|
    tweet_url = TweetUrl.new timestamp, 'user_a_id' => twitter_user_id, 'tweet_url' => at, 'status_id' => status_id
    tweet_url.emit owner_id
  end
  all_hash_tags = HASHTAGS_TRANSFORMER.transform( tweet_hsh)
  tweet_hsh['all_hash_tags'] = all_hash_tags.to_json
  all_hash_tags.each do |at|
    hashtag = Hashtag.new timestamp,  'user_a_id' => twitter_user_id, 'hashtag' => at, 'status_id' => status_id
    hashtag.emit owner_id
  end
  Tweet.new(timestamp, tweet_hsh).emit owner_id
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
  [ resource, screen_name, page, origin, timestamp, raw ]
end


#
# The issue -- when we get a followers page, we know the
# screen name but not the native ID.
#
# So we have to emit a 'BFollowsA', clean it up in the reduce stage, and then be
# stuck with an indeterminate (but harmless) # of duplicate a->b follower links
#

# ===========================================================================
#
# parse each line in STDIN
#
$stdin.each do |line|
  line.chomp! ; next if line.blank?
  resource, screen_name, page, origin, timestamp, raw = load_line(line); next if raw.blank?
  track_count screen_name[0..1].downcase, 100
  # $stderr.puts("parsing %-15s\t%-31s\t%7d\t%s" % [resource, screen_name, page, timestamp])
  case resource
  when 'raw_followers', 'raw_friends'
    raw.each do |hsh|
      next if hsh.blank? || (! hsh.is_a?(Hash))
      hsh['id'] = "%012d"%hsh['id'].to_i if hsh['id']
      #
      # user
      emit_user hsh, timestamp, true
      #
      # follower or friend
      if resource == 'raw_followers'
        # follower: this person *follows* the file owner
        AFollowsB.new(timestamp,
          'user_a' => hsh['screen_name'], 'user_a_id' => hsh['id'],
          'user_b' => screen_name).emit(screen_name)
      else
        # friend: this person is *followed by* the file owner.
        BFollowsA.new(timestamp,
          'user_a' => hsh['screen_name'], 'user_a_id' => hsh['id'],
          'user_b' => screen_name).emit(screen_name)
      end
      #
      # tweet
      tweet_hsh  = hsh['status'] or next
      tweet_hsh['twitter_user'   ] = hsh['screen_name']
      tweet_hsh['twitter_user_id'] = "%012d"%hsh['id'].to_i
      tweet_hsh['id']              = "%012d"%tweet_hsh['id'].to_i
      emit_tweet tweet_hsh, timestamp
    end
  when 'raw_userinfo'
    emit_user raw, timestamp, false
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
