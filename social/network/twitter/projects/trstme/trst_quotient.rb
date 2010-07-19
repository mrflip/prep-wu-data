#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'trstrank_table'

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
end

Wukong::Script.new(Mapper, nil).run
