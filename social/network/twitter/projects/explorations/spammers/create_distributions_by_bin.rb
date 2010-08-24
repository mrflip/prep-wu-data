#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'

# just use wukong to group by bin

class Grouper < Wukong::Streamer::AccumulatingReducer
  attr_accessor :hist
  
  def start! bin, rank
    self.hist = []
  end

  def accumulate bin, rank
    self.hist << rank
  end

  def finalize &blk
    yield [key, hist.join(',')]
  end
  
end

Wukong::Script.new(nil, Grouper).run
