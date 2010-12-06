#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'configliere' ; Configliere.use(:commandline, :env_var, :define)

class Mapper < Wukong::Streamer::RecordStreamer
  def process screen_name, user_id, trstrank, tq, *_
    xml = "<Trstrank user_id=\"%s\" screen_name=\"%s\" trstrank=\"%s\" tq=\"%s\" />" % [user_id, screen_name, trstrank, tq]
    yield [user_id, screen_name, xml]
  end
end

Wukong::Script.new(Mapper, nil).run
