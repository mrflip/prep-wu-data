#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'json'

class Mapper < Wukong::Streamer::RecordStreamer
  def process *args
    rsrc, user_a_id, user_b_id, rel_type, twid, crat, user_b_sn, in_reply_to_twid = args
    yield [
      rel_type + user_a_id,
      user_b_id,
      twid,
      {
        :created_at => crat,
        :user_b_sn  => user_b_sn,
        :rel_tw_id  => in_reply_to_twid
      }.compact_blank.to_json
    ]
  end

end

Wukong::Script.new(Mapper).run

