#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/lib'
require 'hadoop/tsv'
require 'hadoop/utils'
require 'hadoop/script'
require 'hadoop/streamer'
require 'twitter_friends/json_model'
include Hadoop

# hdp-rm -r fixd/public_timeline
#  ./parse_json.rb --go --public_timeline rawd/bundled/public_timeline fixd/public_timeline/


module ParseJson
  class UserIdMapper < Hadoop::Streamer
    def process context, scraped_at, identifier, filename, json_str
      parsed = JsonUser.new_from_json(json_str, scraped_at)
      unless parsed && parsed.healthy? then bad_record!(context, scraped_at, filename, json_str); return ; end
      user_id = parsed.generate_user_classes(TwitterUserId).first
      puts user_id.output_form if user_id
    end
  end

  class PublicTimelineMapper < Hadoop::Streamer
    def process context, scraped_at, identifier, filename, json_str
      parsed = JsonPublicTimeline.new_from_json(json_str, scraped_at)
      unless parsed && parsed.healthy? then bad_record!(context, scraped_at, filename, json_str); return ; end
      parsed.each do |twitter_user, tweet|
        puts twitter_user.output_form(true) if twitter_user
        puts tweet.output_form(true)        if tweet
      end
    end
  end
end

class UniqWithoutScrapedAt < Hadoop::Streamer
  attr_accessor :records, :last_val

  def reset!
    self.records = []
  end

  # Recognize keys that are mutable
  MUTABLE_RESOURCES_RE = /\A(?:twitter_user)/  
  def mutable resource, key, scraped_at, *rest
    MUTABLE_RESOURCES_RE.match(resource)
  end
  def comparable resource, key, scraped_at, *rest
    if mutable(resource, key, scraped_at, *rest)
      [resource, key, *rest]
    else
      [resource, key, scraped_at, *rest]
    end
  end
  
  def process *record
    # find values without 
    val = comparable(*record)
    return if val == self.last_val
    puts record.join("\t")
    self.last_val = val
  end
  
end


class ParseJsonUsersScript < Hadoop::Script
  def initialize
    process_argv!
    case
    when options[:user]               then self.mapper_klass = ParseJson::UserIdMapper
    when options[:public_timeline]    then self.mapper_klass = ParseJson::PublicTimelineMapper
    else raise "Need to know what I'm parsing: --user, --public_timeline, ..."
    end
    self.reducer_klass = UniqWithoutScrapedAt
  end
end


ParseJsonUsersScript.new.run
