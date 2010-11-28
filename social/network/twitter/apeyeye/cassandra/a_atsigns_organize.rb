#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'json'

class Mapper < Wukong::Streamer::RecordStreamer
  def process *args 
    rsrc, user_a_id, user_b_id, rel_type, twid, crat, user_b_sn, in_reply_to_twid = args
    yield [ [user_a_id, user_b_id].join(':'), twid, 
      {:created_at=>crat, :user_b_sn=>user_b_sn.to_s, :rel_tw_id=>in_reply_to_twid}.compact_blank.to_json ]
  end
end

Wukong::Script.new(Mapper).run

