#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'json'

class Mapper < Wukong::Streamer::RecordStreamer
  def process user_a_id, user_b_id, tweet_id, tweet_meta
    meta_data = JSON.parse(tweet_meta)
    rel_type = user_a_id.slice!(0..1)
    yield ['a_atsigns_b', user_a_id, user_b_id, rel_type, tweet_id, meta_data["created_at"], meta_data["user_b_sn"], meta_data["rel_tw_id"]]
  end
end

Wukong::Script.new(Mapper, nil).run
