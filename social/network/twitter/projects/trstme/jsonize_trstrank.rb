#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'

class Mapper < Wukong::Streamer::RecordStreamer
  
  def process screen_name, user_id, rank, &blk
  end

  def jsonize
  end
  
end

Wukong::Script.new(Mapper, nil).run
