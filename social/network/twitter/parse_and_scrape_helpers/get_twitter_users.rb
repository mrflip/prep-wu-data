#!/usr/bin/env ruby
require 'rubygems'
require 'extlib/class'
require 'wukong'                       ; include Wukong
require 'wuclan/twitter'               ; include Wuclan::Twitter::Model
require 'wuclan/twitter/model/token'

module TwitterUsers
  class Mapper < Wukong::Streamer::StructStreamer
 
 
     def process obj, *_, &block
      case obj
        when TwitterUser
          yield [obj.id,obj.screen_name]
        end
      end
     end

end

# Execute the script
Wukong::Script.new(
  TwitterUsers::Mapper,
  nil
).run
