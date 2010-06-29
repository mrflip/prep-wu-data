#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'json'

class Mapper < Wukong::Streamer::RecordStreamer
  
  def process screen_name, user_id, raw, scaled, &blk
    yield [screen_name, user_id, jsonize(scaled)]
  end

  def jsonize scaled
    hsh = {:trstrank => scaled}
    hsh.to_json
  end
  
end

Wukong::Script.new(Mapper, nil).run
