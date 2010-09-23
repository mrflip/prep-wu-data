#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'

Float.class_eval do def round_to(x) ((10**x)*self).round.to_f/(10.0**x) end ; end
                   
class Rounder < Wukong::Streamer::RecordStreamer
  def process *args
    yield args.map{|x| x.to_f.round_to(2) unless x.empty?}
  end
end

Wukong::Script.new(Rounder, nil).run
