#!/usr/bin/env ruby

require 'rubygems'
require 'wukong' ; include Wukong
require 'wuclan/twitter' ; include Wuclan::Twitter::Model
require 'wuclan/twitter/model/token'

class ZeroPaddingDeath < Wukong::Streamer::StructStreamer
  def process thing, *_, &blk
    case thing
    when AFollowsB then
      thing.user_a_id = thing.user_a_id.to_i
      thing.user_b_id = thing.user_b_id.to_i
    else
      thing.user_id = thing.user_id.to_i
    end
    yield thing
  end
end

Wukong::Script.new(ZeroPaddingDeath, nil).run
