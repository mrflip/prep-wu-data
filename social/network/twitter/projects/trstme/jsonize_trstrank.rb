#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'json'

class Mapper < Wukong::Streamer::RecordStreamer

  def process *args, &blk
    return unless args.length == 4
    yield [args[1], jsonize(args[1], args[0], args[3])]
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
