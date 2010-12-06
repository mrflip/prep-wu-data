#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'                       ; include Wukong
require 'wuclan/twitter'               ; include Wuclan::Twitter
require 'wuclan/twitter/token'
require 'wuclan/twitter/token/word_token'

class TweetTermTokenizer < Wukong::Streamer::StructStreamer
  def process tweet, *_
    WordToken.extract_from_tweet(tweet).each do |token|
      yield token
    end
  end
end

#
# Executes the script
#
Wukong::Script.new(
  TweetTermTokenizer,
  nil,
  :partition_fields => 2,  # rsrc, token
  :sort_fields      => 3,  # rsrc, token, tweet_id
  :reuse_jvms       => true,
  :io_record_percent => 0.4
  ).run
