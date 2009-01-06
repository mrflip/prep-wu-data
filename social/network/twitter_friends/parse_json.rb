#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/lib'
require 'hadoop/tsv'
require 'hadoop/utils'
require 'hadoop/script'
require 'hadoop/streamer'
require 'twitter_friends/json_model'
include Hadoop

module ParseJsonUsers
  class Mapper < Hadoop::Streamer
    attr_accessor :parser
    def initialize options
      case
      when options[:user]               then self.parser = JsonUser
      when options[:public_timeline]    then self.parser = JsonTweet
      end
    end
    def process filename, user_json_str=nil
      return unless user_json_str
      user_id, *_ = self.parser.new_user_models(user_json_str, nil, TwitterUserId)
      return unless user_id
      puts user_id.output_form
    end
  end
end

class ParseJsonUsersScript < Hadoop::Script
  def reduce_command
    '/usr/bin/uniq'
  end
end


ParseJsonUsersScript.new(ParseJsonUsers::Mapper, nil).run
