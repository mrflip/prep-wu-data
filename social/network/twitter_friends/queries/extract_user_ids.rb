#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../lib'

require 'hadoop'                       ; include Hadoop
require 'twitter_friends/struct_model' ; include TwitterFriends::StructModel

#
# See bundle.sh for running pattern
#

module ExtractUserIds
  class Mapper < Hadoop::StructStreamer
    #
    #
    def process thing
      case thing
      when TwitterUser
        user_id = TwitterUserId.new(thing.id, thing.screen_name, '1')
      when TwitterUserPartial, TwitterUserId
        user_id = TwitterUserId.new(thing.id, thing.screen_name, '0')
      else return
      end
      puts user_id.output_form
    end
  end

  class Script < Hadoop::Script
    def reduce_command
      '/usr/bin/uniq'
    end
  end
end

#
# Executes the script
#
ExtractUserIds::Script.new(ExtractUserIds::Mapper, nil).run
