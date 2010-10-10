#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'wuclan/twitter' ; include Wuclan::Twitter
require 'wuclan/twitter/geo'

class Mapper < Wukong::Streamer::RecordStreamer

  #
  # Stream in old style geo obj and yield new style
  #

  # Geo
  # [ :tweet_id,    Bignum]
  # [ :user_id,     Bignum]
  # [ :screen_name, String]  
  # [ :created_at,  Bignum]
  # [ :latitude,     Float]
  # [ :longitude,    Float]
  # [ :place_id,    String]

  def process rsrc, twid, uid, sn, crat, lat, lng, place_id
    yield Geo.new(twid, crat, uid, sn, lng, lat, place_id, nil, nil, nil).to_flat
  end
  
end

Wukong::Script.new(Mapper, nil).run
