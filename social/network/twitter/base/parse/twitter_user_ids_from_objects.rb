#!/usr/bin/env ruby
require 'rubygems'
require 'extlib/class'
require 'wukong'
require 'wuclan/twitter' ; include Wuclan::Twitter
require 'wuclan/twitter/twitter_user'

# ./extract_twitter_user_ids_from_twitter_user_anythings.rb --rm --run \
#   /data/rawd/social/network/twitter/objects/twitter_user\*           \
#   /data/rawd/social/network/twitter/scrape_stats/twitter_user_ids


class Mapper < Wukong::Streamer::StructStreamer
  #
  # Pull out all the user Ids we've ever seen
  #
  def process thing, *_
    case thing
    when TwitterUserId then
      thing.user_id = thing.user_id.to_i
      return if thing.user_id == 0
      yield thing
    when TwitterUser then
      thing.user_id = thing.user_id.to_i
      return if thing.user_id == 0
      yield TwitterUserId.new(
        thing.user_id, thing.scraped_at, thing.screen_name, thing.protected,
        thing.followers_count, thing.friends_count, thing.statuses_count, thing.favourites_count,
        thing.created_at, nil, 1)
      # when TwitterUserSearchId
      #   return if thing.sid.to_i == 0
      #   yield TwitterUserId.new('', '', thing.screen_name, '', '', '', '', '', '', thing.suser_id, 1)
    when TwitterUserPartial
      thing.user_id = thing.user_id.to_i
      return if thing.user_id == 0
      yield TwitterUserId.new(thing.user_id, nil, thing.screen_name, thing.protected, thing.followers_count)
    when AFollowsB
      thing.user_a_id = thing.user_a_id.to_i
      thing.user_b_id = thing.user_b_id.to_i
      return if (thing.user_a_id == 0) || (thing.user_b_id == 0)
      yield TwitterUserId.new(thing.user_a_id)
      yield TwitterUserId.new(thing.user_b_id)
    when Tweet
      thing.user_id     = thing.user_id.to_i
      thing.in_reply_to_user_id = thing.in_reply_to_user_id.to_i
      return if thing.user_id == 0
      yield TwitterUserId.new(thing.user_id,nil,thing.screen_name)
      yield TwitterUserId.new(thing.in_reply_to_user_id, nil, thing.in_reply_to_screen_name) unless (thing.in_reply_to_user_id == 0)
    end
  end
end

class Reducer < Wukong::Streamer::AccumulatingReducer
  attr_accessor :twitter_user_id
  def get_key rsrc, user_id, *_
    user_id
  end
  def start! *args
    self.twitter_user_id = TwitterUserId.new(nil)
  end
  def accumulate rsrc, *args
    user_id, scraped_at, screen_name, is_protected,
    followers_count, friends_count, statuses_count, favourites_count,
    created_at, sid, is_full = args.map{|a| a.blank? ? nil : a }
    self.twitter_user_id.user_id              ||= user_id
    self.twitter_user_id.scraped_at        = [scraped_at.to_i      , twitter_user_id.scraped_at.to_i      ].max
    self.twitter_user_id.screen_name     ||= screen_name
    self.twitter_user_id.protected         = 1 if (is_protected.to_i == 1)
    self.twitter_user_id.followers_count   = [followers_count.to_i , twitter_user_id.followers_count.to_i ].max
    self.twitter_user_id.friends_count     = [friends_count.to_i   , twitter_user_id.friends_count.to_i   ].max
    self.twitter_user_id.statuses_count    = [statuses_count.to_i  , twitter_user_id.statuses_count.to_i  ].max
    self.twitter_user_id.favourites_count  = [favourites_count.to_i, twitter_user_id.favourites_count.to_i].max
    self.twitter_user_id.created_at        = created_at unless (created_at.to_i == 0)
    self.twitter_user_id.is_full           = 1 if (is_full.to_i   == 1)
  end
  def set_health twitter_user_id
    case
    when twitter_user_id.screen_name =~ /\W/    then 'bogus_screen_name'
    when twitter_user_id.screen_name =~ /^\d+$/ then 'all_numeric_screen_name'
    when (twitter_user_id.screen_name.blank?)   then 'missing_sn'
    when (twitter_user_id.protected.to_i == 1)  then 'protected'
    when (twitter_user_id.is_full.to_i   != 1)  then 'partial'
    else nil
    end
  end
  def finalize
    self.twitter_user_id.health = set_health(self.twitter_user_id)
    yield( [['twitter_user_id', twitter_user_id.health].compact.join('-')] + twitter_user_id.to_a )
  end
end

#
# Executes the script
#
Wukong::Script.new(
  Mapper,
  Reducer,
  :sort_fields => 2,
  :partition_fields => 2,
  :reduce_tasks => 148
  ).run
