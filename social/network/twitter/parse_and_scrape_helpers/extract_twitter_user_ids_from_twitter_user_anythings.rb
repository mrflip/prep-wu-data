#!/usr/bin/env ruby

require 'extlib/class'
require 'wukong'
require 'wuclan/twitter'
require 'wuclan/twitter/model'               ; include Wuclan::Twitter::Model


module GenUserIds
  class Mapper < Wukong::Streamer::StructStreamer
    include Wuclan::Twitter::Model
    #
    # Pull out all the user Ids we've ever seen
    #
    def process thing, *_
      case thing
      when TwitterUserId then
        return if thing.id.to_i == 0
        yield thing
      when TwitterUser then
        return if thing.id.to_i == 0
        yield TwitterUserId.new(
          thing.id, thing.scraped_at, thing.screen_name, thing.protected,
          thing.followers_count, thing.friends_count, thing.statuses_count, thing.favorites_count,
          thing.created_at, nil, 1)
        # when TwitterUserSearchId
        #   return if thing.sid.to_i == 0
        #   yield TwitterUserId.new('', '', thing.screen_name, '', '', '', '', '', '', thing.sid, 1)
      when TwitterUserPartial
        return if thing.id.to_i == 0
        yield TwitterUserId.new(thing.id, nil, thing.screen_name, thing.protected, thing.followers_count)
      when AFollowsB
        return if (thing.user_a_id.to_i == 0) || (thing.user_b_id.to_i == 0)
        yield TwitterUserId.new(thing.user_a_id)
        yield TwitterUserId.new(thing.user_b_id)
      when Tweet
        return if thing.twitter_user_id.to_i == 0
        yield TwitterUserId.new(thing.twitter_user_id)
        yield TwitterUserId.new(thing.in_reply_to_user_id) unless (thing.in_reply_to_user_id.to_i == 0)
      end
    end

  end

  class Reducer < Wukong::Streamer::AccumulatingReducer
    attr_accessor :twitter_user_id
    def get_key rsrc, id, *_
      id
    end
    def start! *args
      self.twitter_user_id = TwitterUserId.new(nil)
    end
    def accumulate rsrc, *args
      id, scraped_at, screen_name, protected,
      followers_count, friends_count, statuses_count, favourites_count,
      created_at, sid, is_full = args.map{|a| a.blank? ? nil : a }
      self.twitter_user_id.id              ||= id
      self.twitter_user_id.scraped_at        = [scraped_at.to_i      , twitter_user_id.scraped_at.to_i      ].max
      self.twitter_user_id.screen_name     ||= screen_name
      self.twitter_user_id.protected         = 1 if (protected.to_i == 1)
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
      twitter_user_id.id     = "%010d" % twitter_user_id.id.to_i
      twitter_user_id.health = set_health(twitter_user_id)
      yield( [['twitter_user_id', twitter_user_id.health].compact.join('-')] + twitter_user_id.to_a )
    end
  end

  class Script < Wukong::Script
    def default_options
      super.merge :sort_fields => 2
    end
  end
end

#
# Executes the script
#
GenUserIds::Script.new(GenUserIds::Mapper, GenUserIds::Reducer).run
