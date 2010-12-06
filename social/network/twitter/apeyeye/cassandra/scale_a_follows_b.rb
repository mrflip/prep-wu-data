#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'

class Mapper < Wukong::Streamer::RecordStreamer
  def process *args
    followers = args.size - 1
    return unless followers < 1000
      yield args
  end
end

Wukong::Script.new(
  Mapper, nil).run

