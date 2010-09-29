#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'wukong/and_pig'

class Mapper < Wukong::Streamer::RecordStreamer
  def process term, size, pbag, *_
    yield [term, freqs(pbag).join(",")] if size.to_i > 20
  end

  def freqs pbag
    pbag.from_pig_bag.map{|s, n| s.to_f / n.to_f}
  end
  
end

Wukong::Script.new(Mapper, nil).run
