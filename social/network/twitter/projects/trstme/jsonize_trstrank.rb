#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'json'

class Mapper < Wukong::Streamer::RecordStreamer

  def process *args, &blk
    return unless args.length == 4
    sn, uid, rank, tq = args
    yield [uid, jsonize(uid, sn, rank, tq)]
  end

  def jsonize user_id, screen_name, scaled, tq
    hsh = {:user_id => user_id, :screen_name => screen_name, :trstrank => scaled, :tq => tq}
    hsh.to_json
  end

end

Wukong::Script.new(Mapper, nil).run
