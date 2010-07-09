#!/usr/bin/env ruby
require 'rubygems'
require 'extlib/class'
require 'wukong'                       ; include Wukong
require 'wuclan/twitter'               ; include Wuclan::Twitter::Model
require 'wuclan/twitter/model/token'

module ExtractTweetTokens
  class Mapper < Wukong::Streamer::StructStreamer
    #
    # Extract semantic info from tweets. NOT tweet-noids!!
    #  re-tweets,
    #  replies and atsigns,
    #  hashtags,
    #  smileys,
    #  embedded urls,
    #  stock tokens,
    #  word_tokens
    #
    def process tweet, *_, &block
        tweet.retweets     &block
        tweet.replies      &block
        tweet.atsigns      &block
        tweet.hashtags     &block
        tweet.smileys      &block
        tweet.tweet_urls   &block
        tweet.stock_tokens &block
        #tweet.word_tokens  &block
    end
  end

end

#
# Executes the script
#
Wukong::Script.new(
  ExtractTweetTokens::Mapper,
  nil,
  :partition_fields => 2,  # rsrc, token
  :sort_fields      => 3,  # rsrc, token, tweet_id
  :reuse_jvms       => true
  ).run
