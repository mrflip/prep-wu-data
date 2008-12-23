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
# Load the data model
#
require 'twitter_flat_model.rb'

def repair_id hsh, id_attr
  hsh[id_attr] = "%012d"%hsh[id_attr].to_i
end

# ===========================================================================
#
# transform and emit User
#
def emit_user hsh, scraped_at, is_partial
  hsh['protected']  = hsh['protected'] ? 1 : 0
  repair_date_attr(hsh, 'created_at')
  scrub hsh, :name, :location, :description, :url
  if is_partial
    TwitterUserPartial.new_from_hash(scraped_at, hsh).emit
  else
    TwitterUser.new_from_hash(       scraped_at, hsh).emit
    TwitterUserProfile.new_from_hash(scraped_at, hsh).emit
    TwitterUserStyle.new_from_hash(  scraped_at, hsh).emit
  end
end

# ===========================================================================
#
# Transform tweet
#
ATSIGNS_TRANSFORMER   = RegexpRepeatedTransformer.new('text', RE_ATSIGNS)
HASHTAGS_TRANSFORMER  = RegexpRepeatedTransformer.new('text', RE_HASHTAGS)
TWEETURLS_TRANSFORMER = RegexpRepeatedTransformer.new('text', RE_URL)
def emit_tweet tweet_hsh
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
  tweet_hsh['favorited']  = tweet_hsh['favorited'] ? 1 : 0
  tweet_hsh['truncated']  = tweet_hsh['truncated'] ? 1 : 0
  tweet_hsh['tweet_len']  = tweet_hsh['text'].length
  #
  # Emit
  #
  repair_date_attr(tweet_hsh, 'created_at')
  scraped_at      = tweet_hsh['created_at']     # Tweets are immutable
  status_id       = tweet_hsh['id']
  twitter_user    = tweet_hsh['twitter_user']
  twitter_user_id = tweet_hsh['twitter_user_id']
  owner_id        = twitter_user                # emit using twitter_user as key so all group together.
  #
  if tweet_hsh['in_reply_to_user_id'] then
    at                    = repair_id(tweet_hsh, 'in_reply_to_user_id')
    in_reply_to_status_id = repair_id(tweet_hsh, 'in_reply_to_status_id')
    reply    = ARepliedB.new_from_hash( scraped_at, 'user_a_id' => twitter_user_id, 'user_b_id'   => at, 'status_id' => status_id, 'in_reply_to_status_id' => in_reply_to_status_id).emit
  end
  ATSIGNS_TRANSFORMER.transform(  tweet_hsh).each do |at|
    atsign    = AAtsignsB.new_from_hash(scraped_at, 'user_a_id' => twitter_user_id, 'user_b_name'  => at, 'user_a_name' => twitter_user, 'status_id' => status_id).emit
  end
  TWEETURLS_TRANSFORMER.transform(tweet_hsh).each do |at|
    tweet_url = TweetUrl.new_from_hash( scraped_at, 'user_a_id' => twitter_user_id, 'tweet_url'   => at, 'status_id' => status_id).emit
  end
  HASHTAGS_TRANSFORMER.transform( tweet_hsh).each do |at|
    hashtag   = Hashtag.new_from_hash(  scraped_at, 'user_a_id' => twitter_user_id, 'hashtag'     => at, 'status_id' => status_id).emit
  end
  Tweet.new_from_hash(scraped_at, tweet_hsh).emit
end

# ===========================================================================
#
# Parse the line
#
def load_line line
  m = %r{^(\w+)\t(\d+)\t(user|followers|friends)\t(\d+)\t([\d\-]{14,15})\t(.*)$}.match(line)
  if !m then warn "Can't grok #{line}"; return [] ; end
  screen_name, twitter_user_id, context, page, scraped_at, json = m.captures
  begin
    raw = JSON.load(json)
  rescue Exception => e
    warn "Couldn't open and parse #{[screen_name, twitter_user_id, context, page, scraped_at].join('-')}: #{e}"
    return []
  end
  [ screen_name, twitter_user_id, context, page, scraped_at, raw ]
end

# ===========================================================================
#
# Suck all the sweet juicy info in each line
#
def parse_keyed_file
  $stdin.each do |line|
    line.chomp! ; next if line.blank?
    file_owner_name, file_owner_id, context, page, scraped_at, raw = load_line(line); next if raw.blank?
    # track_count file_owner_name[0..1].downcase, 100
    case context
    when 'followers', 'friends'
      #
      # A list of followers or friends, each with one tweet and a partial_user
      #
      raw.each do |hsh|
        next if hsh.blank? || (! hsh.is_a?(Hash)) || (hsh['screen_name']=='')
        repair_id(hsh, 'id')
        #
        # Register the follower / friend relationship
        #
        if context == 'followers'
          # follower: this person *follows* the file owner
          AFollowsB.new_from_hash(scraped_at,
            'user_a_id' => hsh['id'],     'user_a_name' => hsh['screen_name'],
            'user_b_id' => file_owner_id, 'user_b_name' => file_owner_name   ).emit
        else
          # friend: this person is *followed by* the file owner.
          AFollowsB.new_from_hash(scraped_at,
            'user_a_id' => file_owner_id, 'user_a_name' => file_owner_name,
            'user_b_id' => hsh['id'],     'user_b_name' => hsh['screen_name'] ).emit
        end
        #
        # Make note of the user
        #
        emit_user hsh, scraped_at, true
        #
        # Grab the tweet
        #
        tweet_hsh  = hsh['status'] or next
        tweet_hsh['twitter_user'   ] = hsh['screen_name']
        tweet_hsh['twitter_user_id'] = repair_id(hsh,       'id')
        tweet_hsh['id']              = repair_id(tweet_hsh, 'id')
        emit_tweet tweet_hsh
      end
    when 'user'
      #
      # Make note of the user
      #
      repair_id(raw, 'id')
      emit_user raw, scraped_at, false
    else
      raise "Crap bubbles -- unexpected context #{context}"
    end
  end
end

def parse_flat_tweets
  $stdin.each do |line|
    line.chomp! ; next if line.blank?
    begin
      raw = JSON.load(line)
    rescue Exception => e
      warn "Couldn't open and parse #{line[0..100]}: #{e}"
      next
    end
    #
    # A list of tweets including user
    #
    raw.each do |tweet_hsh|
      next if tweet_hsh.blank? || (! tweet_hsh.is_a?(Hash)) || (tweet_hsh['user'].blank?)
      repair_id(tweet_hsh, 'id')
      user_hsh = tweet_hsh['user']
      next unless user_hsh['screen_name']
      #
      # Make note of the user
      #
      repair_id(user_hsh, 'id')
      scraped_at = repair_date_attr(tweet_hsh, 'created_at')
      emit_user user_hsh, scraped_at, true
      #
      # Grab the tweet
      #
      tweet_hsh['twitter_user'   ] = user_hsh['screen_name']
      tweet_hsh['twitter_user_id'] = user_hsh['id']
      emit_tweet tweet_hsh
    end # tweet
  end # file
end


case ARGV[0]
when '--keyed'    then parse_keyed_file
when '--tweets'   then parse_flat_tweets
else raise "Need to specify an argument: --map, --reduce"
end
