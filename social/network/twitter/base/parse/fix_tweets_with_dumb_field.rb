#!/usr/bin/env ruby

require 'rubygems'
require 'wukong' ; include Wukong
require 'wuclan/twitter/model' ; include Wuclan::Twitter::Model

class Mapper < Wukong::Streamer::StructStreamer
  def process shitty_tweet, *_
    tweet = shitty_tweet.to_flat
    yield shitty_tweet.to_flat[0..14]
  end
end


Wukong::Script.new(Mapper, nil).run
