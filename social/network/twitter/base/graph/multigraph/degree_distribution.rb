#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'

#
# Just calculate in and out degree distribution for everything.
#

class Mapper < Wukong::Streamer::RecordStreamer
  def process rsrc, user_a_id, user_b_id, *_
    yield [rsrc, "out", user_a_id, user_b_id]
    yield [rsrc, "in", user_b_id, user_a_id]
  end
end

class Reducer < Wukong::Streamer::AccumulatingReducer
  attr_accessor :user_id, :rep_out, :rep_in, :ats_out, :ats_in, :ret_out, :ret_in, :fav_out, :fav_in

  def get_key rsrc, thing, user_a_id, user_b_id, *_
    [rsrc, user_a_id.to_i]
  end

  def start! rsrc, thing, user_a_id, user_b_id, *_
    self.user_id = user_a_id
    self.rep_out = 0
    self.ats_out = 0
    self.ret_out = 0
    self.fav_out = 0
    self.rep_in  = 0
    self.ats_in  = 0
    self.ret_out = 0
    self.fav_out = 0
  end

  #
  # Yuck. Is there a cleaner way?
  #
  def accumulate rsrc, thing, user_a_id, user_b_id, *_
    case rsrc
    when "a_replies_b" then
      if thing == "out"
        self.rep_out += 1
      else
        self.rep_in += 1
      end
    when "a_atsigns_b" then
      if thing == "out"
        self.ats_out += 1
      else
        self.ats_in += 1
      end
    when "a_retweets_b" then
      if thing == "out"
        self.ret_out += 1
      else
        self.ret_in += 1
      end
    when "a_favorites_b" then
      if thing == "out"
        self.fav_out += 1
      else
        self.fav_in += 1
      end
    end
  end

  def finalize
    yield [user_id, rep_out, rep_in, ats_out, ats_in, ret_out, ret_in, fav_out, fav_in]
  end

end

Wukong::Script.new(
  Mapper,
  Reducer,
  :sort_fields => 3,
  :partition_fields => 3
  ).run
