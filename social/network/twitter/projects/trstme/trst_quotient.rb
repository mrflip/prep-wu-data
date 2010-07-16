#!/usr/bin/env ruby

require 'wukong'
require 'trstrank_table'

class Mapper < Wukong::Streamer::RecordStreamer
  def process *args
    return unless args.length == 3
    uid, followers, scaled = args
    scaled = (scaled.to_f*10.0).round.to_f/10.0
    yield [uid, TRSTRANK_TABLE[followers][scaled]]
  end
end

Wukong::Script.new(Mapper, nil).run
