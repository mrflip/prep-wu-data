#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'

Float.class_eval do def round_to(x) ((10**x)*self).round end ; end

class Mapper < Wukong::Streamer::RecordStreamer
  def process tq, followers
    yield [logbin(followers), tq]
  end

  def logbin(x)
    begin
      Math.log10(x.to_f).round_to(1)
    rescue Errno::ERANGE
      return 0.01
    end
  end

end

Wukong::Script.new(Mapper, nil).run

