#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'json'

class Mapper < Wukong::Streamer::RecordStreamer

  def process screen_name, user_id, raw, scaled, &blk
    yield [screen_name, user_id, jsonize(user_id, screen_name, scaled)]
  end

  def jsonize user_id, screen_name, scaled
    hsh = {:user_id => user_id, :screen_name => screen_name, :trstrank => scaled, :ics_updated_at => right_now}
    hsh.to_json
  end

  def right_now
    Time.now.strftime("%Y%m%d")
  end

end

Wukong::Script.new(Mapper, nil).run
