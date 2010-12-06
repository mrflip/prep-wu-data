#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'

class Reducer < Wukong::Streamer::AccumulatingReducer
  attr_accessor :key_count
  def get_key *args
    args[2]
  end
  def start!(*args) self.key_count = 0 end
  def accumulate(*args) self.key_count += 1 end
  def finalize
    yield [ key, key_count ]
  end
end
