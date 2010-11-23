#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'set'

class Mapper < Wukong::Streamer::RecordStreamer
  def process *args
    rsrc, user_a_id, user_b_id, rel_type, tweet_id, created_at, user_b_sn, in_reply_to_sn = args
    yield [rel_type + user_a_id, user_b_id]
  end
end

class Reducer < Wukong::Streamer::AccumulatingReducer
  attr_accessor :rels
  def start! rel_user_a_id, user_b_id
    @rels = Set.new
  end

  def accumulate rel_user_a_id, user_b_id
    @rels << user_b_id
  end

  def finalize
    yield [key, rels.to_a]
  end
  
end

Wukong::Script.new(Mapper, Reducer, :reduce_tasks => '60').run
