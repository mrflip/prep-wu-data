#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'

#
# Needs as input the joined influencer metrics, dumps out everything for the api call
#
class Mapper < Wukong::Streamer::RecordStreamer

  def process uid, sn, crat, tw_out, tw_in, rep_out, rep_in, ats_out, ats_in, ret_out, ret_in, fav_out, fav_in, &blk
    days = days_since_created(crat)
    yield [uid, sn, crat, days, tw_out.to_i/days, tw_in.to_i/days, rep_out.to_i/days, rep_in.to_i/days, ats_out.to_i/days, ats_in.to_i/days, ret_out.to_i/days, ret_in.to_i/days, fav_out.to_i/days, fav_in.to_i/days]
  end

  def days_since_created crat
    right_now.to_i - crat.to_i
  end

  def right_now
    Time.now.strftime("%Y%m%d")
  end

end

Wukong::Script.new(Mapper, nil).run
