#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'

class Mapper < Wukong::Streamer::RecordStreamer
  def process t, twid, s, n, r_t, r_t_sq, v
    yield [t, r_t]
  end
end

Wukong::Script.new(
  Mapper,
  nil,
  :min_split_size => '536870912'
  ).run
