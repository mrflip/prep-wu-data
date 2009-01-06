#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/lib'
require 'hadoop/tsv'
require 'hadoop/utils'
require 'hadoop/script'
require 'hadoop/streamer'
require 'twitter_friends/json_model'
include Hadoop

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
        puts twitter_user.output_form if twitter_user
        puts tweet.output_form        if tweet
      end
    end
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
    self.reducer_klass = nil
  end
  
  def reduce_command
    '/usr/bin/uniq'
  end
end


ParseJsonUsersScript.new.run
