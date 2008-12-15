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

#
# Load the data model
#
require 'twitter_flat_model.rb'

# transform and emit User
#
def emit_user hsh, timestamp, is_partial
  hsh['protected']  = hsh['protected'] ? 1 : 0
  hsh['created_at']  = DateTime.parse(hsh['created_at']).strftime(DATEFORMAT) if hsh['created_at']
  scrub hsh, :name, :location, :description, :url
  if is_partial
    TwitterUserPartial.new(timestamp, hsh).emit
  else
    TwitterUser.new(       timestamp, hsh).emit
    TwitterUserProfile.new(timestamp, hsh).emit
    TwitterUserStyle.new(  timestamp, hsh).emit
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
    in_reply_to_status_id = "%012d"%tweet_hsh['in_reply_to_status_id']
    reply = ARepliedB.new timestamp, 'id' => twitter_user_id,
      'user_a_id' => twitter_user_id, 'user_a_name' => twitter_user,
      'user_b_id' => at,
      'status_id' => status_id, 'in_reply_to_status_id' => in_reply_to_status_id
    reply.emit
  end
  all_atsigns = ATSIGNS_TRANSFORMER.transform(  tweet_hsh)
  tweet_hsh['all_atsigns'] =  all_atsigns.to_json
  all_atsigns.each do |at|
    atsign = AAtsignsB.new timestamp,
      'user_a_id' => twitter_user_id, 'user_a_name' => twitter_user,
                                      'user_b_name'  => at, 'status_id' => status_id
    atsign.emit
  end
  all_tweeted_urls = TWEETURLS_TRANSFORMER.transform(tweet_hsh)
  tweet_hsh['all_tweeted_urls'] = all_tweeted_urls.to_json
  all_tweeted_urls.each do |at|
    tweet_url = TweetUrl.new timestamp, 'user_a_id' => twitter_user_id, 'tweet_url' => at, 'status_id' => status_id
    tweet_url.emit
  end
  all_hash_tags = HASHTAGS_TRANSFORMER.transform( tweet_hsh)
  tweet_hsh['all_hash_tags'] = all_hash_tags.to_json
  all_hash_tags.each do |at|
    hashtag = Hashtag.new timestamp,  'user_a_id' => twitter_user_id, 'hashtag' => at, 'status_id' => status_id
    hashtag.emit
  end
  Tweet.new(timestamp, tweet_hsh).emit
end


#
#
def load_line line
  m = %r{^(\w+)\t(\d+)\t(user|followers|friends)\t(\d+)\t(\d{8}-\d{6})\t(.*)$}.match(line)
  if !m then warn "Can't grok #{line}"; return [] ; end
  screen_name, twitter_user_id, context, page, timestamp, json = m.captures
  begin
    raw = JSON.load(json)
  rescue Exception => e
    warn "Couldn't open and parse #{[screen_name, twitter_user_id, context, page, timestamp].join('-')}: #{e}"
    return []
  end
  origin = [screen_name, twitter_user_id, context, page, timestamp].join('-')
  [ screen_name, twitter_user_id, context, page, timestamp, origin, raw ]
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
  file_owner_name, file_owner_id, context, page, timestamp, origin, raw = load_line(line); next if raw.blank?
  track_count file_owner_name[0..1].downcase, 100
  case context
  when 'followers', 'friends'
    raw.each do |hsh|
      next if hsh.blank? || (! hsh.is_a?(Hash))
      hsh['id'] = "%012d"%hsh['id'].to_i if hsh['id']
      #
      # user
      emit_user hsh, timestamp, true
      #
      # follower or friend
      if context == 'followers'
        # follower: this person *follows* the file owner
        AFollowsB.new(timestamp,
          'user_a_id' => hsh['id'],     'user_a_name' => hsh['screen_name'],
          'user_b_id' => file_owner_id, 'user_b_name' => file_owner_name   ).emit
      else
        # friend: this person is *followed by* the file owner.
        AFollowsB.new(timestamp,
          'user_a_id' => file_owner_id, 'user_a_name' => file_owner_name,
          'user_b_id' => hsh['id'],     'user_b_name' => hsh['screen_name'] ).emit
      end
      #
      # tweet
      tweet_hsh  = hsh['status'] or next
      tweet_hsh['twitter_user'   ] = hsh['screen_name']
      tweet_hsh['twitter_user_id'] = "%012d"%hsh['id'].to_i
      tweet_hsh['id']              = "%012d"%tweet_hsh['id'].to_i
      emit_tweet tweet_hsh, timestamp
    end
  when 'user'
    raw['id'] = "%012d"%raw['id'].to_i if raw['id']
    # warn ("WTF id mismatch: #{raw['id']} -- #{file_owner_id}") unless raw['id'] == file_owner_id
    emit_user raw, timestamp, false
  else
    raise "Crap bubbles -- unexpected context #{context}"
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
