#!/usr/bin/env ruby

# currently not in use...

require 'rubygems'
require 'wukong'

class AFollowsBRemapper < Wukong::Streamer::RecordStreamer
  def process *args
    return unless args
    return unless args.length == 3
    rsrc, user_a_id, user_b_id = args
    yield ["#{user_a_id}:#{user_b_id}", "ab", "0"]
    yield ["#{user_b_id}:#{user_a_id}", "ba", "0"]
  end
end

Wukong::Script.new(AFollowsBRemapper, nil).run
