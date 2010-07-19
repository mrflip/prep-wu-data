#!/usr/bin/env ruby

$: << File.dirname(__FILE__)

require 'rubygems'
require 'wukong'
require 'trstrank_table'

Float.class_eval do def round_to(x) ((10**x)*self).round end ; end

class Mapper < Wukong::Streamer::RecordStreamer
  def process *args
    return unless args.length == 3
    uid, followers, scaled = args
    rank = (scaled.to_f*10.0).round.to_f/10.0
    bin  = TRSTRANK_TABLE["#{logbin(followers)}"]
    return if bin.blank?
    tq = bin[rank].round
    yield [uid, scaled, tq]
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
