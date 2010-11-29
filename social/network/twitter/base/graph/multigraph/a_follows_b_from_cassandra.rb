#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'

class Mapper < Wukong::Streamer::RecordStreamer
  def process user_a_id, *list
    list.each do |user_b_id|
      yield ['a_follows_b', user_a_id, user_b_id]
    end
  end
end

Wukong::Script.new(Mapper, nil).run
