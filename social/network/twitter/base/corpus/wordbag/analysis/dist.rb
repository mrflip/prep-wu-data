#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'

class Mapper < Wukong::Streamer::RecordStreamer
  def process term, freq
    yield [term, freq]
  end
end

class Reducer < Wukong::Streamer::AccumulatingReducer
  attr_accessor :dist
  def start! term, freq
    @dist = []
  end

  def accumulate term, freq
    dist << freq
  end

  # yield up to 1000 points, are they ordered or?
  def finalize
    dist.sort_by{ rand }[0..1000].each{|f| yield [key, f]}
  end
  
end


Wukong::Script.new(Mapper, Reducer).run
