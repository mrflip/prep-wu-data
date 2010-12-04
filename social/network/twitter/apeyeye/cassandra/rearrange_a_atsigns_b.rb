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

class Reducer < Wukong::Streamer::AccumulatingReducer
  attr_accessor :convs

  def get_key rel_user_a_id, user_b_id, *_
    [rel_user_a_id, user_b_id]
  end
  
  def start! rel_user_a_id, user_b_id, *_
    @convs = []
  end

  def accumulate rel_user_a_id, user_b_id, *rest
    @convs << rest.flatten
  end

  def finalize
    yield [key, convs]
  end
  
end

Wukong::Script.new(
  Mapper,
  Reducer,
  :partition_fields => 2,
  :sort_fields      => 2,
  :reduce_tasks     => '40'
  ).run

