#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'json'

class Mapper < Wukong::Streamer::RecordStreamer

  def process screen_name, user_id, raw, scaled, &blk
    yield [screen_name, user_id, jsonize(scaled)]
  end

  def jsonize scaled
    hsh = {:trstrank => scaled, :last_calculated => right_now}
    hsh.to_json
  end

  def right_now
    Time.now.strftime("%Y%m%d")
  end

end

Wukong::Script.new(Mapper, nil).run
