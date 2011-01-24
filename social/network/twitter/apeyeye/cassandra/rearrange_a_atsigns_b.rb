#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'json'

#
# Yields (row_key, super_col_name, col_name, col_vale)
#
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

#
# Groups (row_key, super_col_name, col_name, col_vale) by row_key and creates a
# big json hash for mumakil:
#
# {'super_col_name' => {'col_name' => 'col_value', ...}, ...}
#
class Reducer < Wukong::Streamer::AccumulatingReducer
  attr_accessor :convs

  def start! row_key, super_col_name, col_name, col_value
    @convs = Hash.new{|h,k| h[k] = {}}
  end

  def accumulate row_key, super_col_name, col_name, col_value
    @convs[super_col_name][col_name] = col_value
  end

  def finalize
    yield [key, convs.to_json]
  end

end

Wukong::Script.new(
  Mapper,
  Reducer,
  :partition_fields => 2,
  :sort_fields      => 2,
  :reduce_tasks     => '40'
  ).run

