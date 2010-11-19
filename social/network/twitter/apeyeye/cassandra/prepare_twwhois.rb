#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'

class Mapper < Wukong::Streamer::RecordStreamer
  def process *args
    screen_name, user_id = [args[3], args[1]]
    yield [screen_name.downcase, user_id] if !screen_name.blank? && !user_id.blank?
  end
end

Wukong::Script.new(Mapper, nil).run
