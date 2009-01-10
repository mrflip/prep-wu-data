#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/lib'

require 'hadoop'
require 'twitter_friends/struct_model' ; include TwitterFriends::StructModel
require 'twitter_friends/json_model'   ; include TwitterFriends::JsonModel

# rsrc=public_timeline ;
# hdp-rm -r fixd/$rsrc
# ./parse_json.rb --go --public_timeline rawd/bundled/$rsrc fixd/$rsrc/


module ParseJson
  class UserMapper < Hadoop::Streamer
    def process context, scraped_at, user_id, page, moreinfo, json_str
      return if context =~ /^bogus-/
      parsed = JsonTwitterUser.new_from_json(json_str, scraped_at)
      unless parsed && parsed.healthy? then bad_record!(context, scraped_at, user_id, page, moreinfo, json_str); return ; end
      parsed.generate_user_profile_and_style.each do |user_obj|
        puts user_obj.output_form(true) if user_obj
      end
      tweet = parsed.generate_tweet; puts tweet.output_form(true) if tweet
    end
  end

  class FriendsFollowersMapper < Hadoop::Streamer
    def process context, scraped_at, user_a_id, page, screen_name, json_str
      return if context =~ /^bogus-/
      parsed = FriendsFollowersParser.new_from_json(json_str, context, scraped_at, user_a_id)
      unless parsed && parsed.healthy? then bad_record!(context, scraped_at, user_a_id, page, screen_name, json_str); return ; end
      parsed.each do |twitter_user, tweet, relationship|
        puts twitter_user.output_form(true) if twitter_user
        puts tweet.output_form(true)        if tweet
        puts relationship.output_form(true) if relationship
      end
    end
  end

  class PublicTimelineMapper < Hadoop::Streamer
    def process context, scraped_at, identifier, page, moreinfo, json_str
      return if context =~ /^bogus-/
      parsed = PublicTimelineParser.new_from_json(json_str, scraped_at)
      unless parsed && parsed.healthy? then bad_record!(context, scraped_at, identifier, page, moreinfo, json_str); return ; end
      parsed.each do |twitter_user, tweet|
        puts twitter_user.output_form(true) if twitter_user
        puts tweet.output_form(true)        if tweet
      end
    end
  end

  #
  # using UniqByLastReducer
  #
  # class UniqWithoutScrapedAt < Hadoop::Streamer
  #   attr_accessor :records, :last_val
  #
  #   def reset!
  #     self.records = []
  #   end
  #
  #   # Recognize keys that are mutable
  #   MUTABLE_RESOURCES_RE = /\A(?:twitter_user)/
  #   def mutable resource, key, scraped_at, *rest
  #     MUTABLE_RESOURCES_RE.match(resource)
  #   end
  #   def comparable resource, key, scraped_at, *rest
  #     if mutable(resource, key, scraped_at, *rest)
  #       [resource, key, *rest]
  #     else
  #       [resource, key, scraped_at, *rest]
  #     end
  #   end
  #
  #   def process *record
  #     # find values without
  #     val = comparable(*record)
  #     return if val == self.last_val
  #     puts record.join("\t")
  #     self.last_val = val
  #   end
  # end

  class Script < Hadoop::Script
    def initialize
      process_argv!
      case
      when options[:user]                           then self.mapper_klass = ParseJson::UserMapper
      when options[:friends] || options[:followers] then self.mapper_klass = ParseJson::FriendsFollowersMapper
      when options[:favorites]                      then self.mapper_klass = ParseJson::FriendsFollowersMapper
      when options[:public_timeline]                then self.mapper_klass = ParseJson::PublicTimelineMapper
      else raise "Need to know what I'm parsing: --user, --public_timeline, --followers, ..."
      end
      # self.reducer_klass = UniqWithoutScrapedAt
      self.reducer_klass = Hadoop::UniqByLastReducer
    end

    #
    # Sort on <resource   id      scraped_at> (harmlessly using an extra field on immutable rows)
    #
    def sort_fields
      4
    end
  end
end

#
# Executes the script
#
ParseJson::Script.new.run
