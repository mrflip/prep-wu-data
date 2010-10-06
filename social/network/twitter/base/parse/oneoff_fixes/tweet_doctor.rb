#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'wuclan/twitter/model' ; include Wuclan::Twitter::Model


class TweetFixer < Wukong::Streamer::StructStreamer
  #attr_accessor :tweet

  def process tweet, *_
    yield fix_tweet(tweet)
  end

  def fix_tweet tweet
    return tweet if tweet.in_reply_to_status_id.blank?    # tweet is healthy
    return tweet if tweet.in_reply_to_status_id.to_i > 0  # tweet is healthy
    swap_fucked_fields tweet                              # tweet is chronically ill
  end

  #
  # swap fields of fucked up tweets
  #
  def swap_fucked_fields tweet
    source                      = tweet.text
    tweet.text                  = tweet.in_reply_to_status_id
    tweet.in_reply_to_status_id = nil
    tweet.iso_language_code     = tweet.source
    tweet.source                = source
    tweet
  end

end

Wukong::Script.new(TweetFixer, nil).run
