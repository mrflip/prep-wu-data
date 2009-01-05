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
    def process filename, user_json_str
      user_id, *_ = JsonUser.new_user_models(user_json_str, nil, TwitterUserId)
      puts user_id.to_tsv
    end
  end

end

class ParseJsonUsersScript < Hadoop::Script
  def reduce_command
    '/usr/bin/uniq'
  end
end
ParseJsonUsersScript.new(ParseJsonUsers::Mapper, nil).run
