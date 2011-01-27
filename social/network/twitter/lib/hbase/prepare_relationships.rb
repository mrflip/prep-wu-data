#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'json'

#
# Yields (row_key, cf_name, qualifier, col_value)
#
class Mapper < Wukong::Streamer::RecordStreamer
  def process *args
    rsrc, user_a_id, user_b_id, rel_type, twid, crat, user_b_sn, in_reply_to_twid = args
    yield [
      "#{user_a_id}:#{user_b_id}", # row_key
      rel_type,                    # cf_name
      twid,                        # qualifier
      {
        :created_at => crat,
        :user_b_sn  => user_b_sn,
        :rel_tw_id  => in_reply_to_twid
      }.compact_blank.to_json      # column value
    ]
  end

end

Wukong::Script.new(Mapper, nil).run
