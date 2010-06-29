#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'json'

class Mapper < Wukong::Streamer::RecordStreamer

  def process uid, sn, crat, days, tw_out_day, tw_in_day, rep_out_day, rep_in_day, ats_out_day, ats_in_day, rt_out_day, rt_in_day, fav_out_day, fav_in_day
    hsh = {
      :user_id         => uid,
      :screen_name     => sn,
      :created_at      => crat,
      :account_age     => days,
      :ics_updated_at  => right_now,
      :tw_out_day      => tw_out_day,
      :tw_in_day       => tw_in_day,
      :rep_out_day     => rep_out_day,
      :rep_in_day      => rep_in_day,
      :ats_out_day     => ats_out_day,
      :ats_in_day      => ats_in_day,
      :rt_out_day      => rt_out_day,
      :rt_in_day       => rt_in_day,
      :fav_out_day     => fav_out_day,
      :fav_in_day      => fav_in_day
    }
    yield [ screen_name, user_id, hsh.to_json ]
  end

  def right_now
    Time.now.strftime("%Y%m%d")
  end

end


Wukong::Script.new(Mapper, nil).run
