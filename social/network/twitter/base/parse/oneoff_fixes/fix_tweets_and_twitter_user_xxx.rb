#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'wuclan/twitter' ; include Wuclan::Twitter
require 'wuclan/twitter/twitter_user'

class Mapper < Wukong::Streamer::StructStreamer
  
  def process obj, *_
    case obj
    when TwitterUserStyle, TwitterUserProfile, Geo then
      yield obj.to_flat
    when Tweet then
      yield swap_loc_fields(obj)
    end
  end

  def swap_loc_fields tweet
    tmp       = tweet.lat
    tweet.lat = tweet.lng
    tweet.lng = tmp
    tweet.to_flat
  end
  
end

Wukong::Script.new(
  Mapper,
  nil
  ).run
