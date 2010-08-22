#!/usr/bin/env ruby
require 'rubygems'
require 'extlib/class'
require 'wukong'                       ; include Wukong
require 'wuclan/twitter'               ; include Wuclan::Twitter::Model
require 'wuclan/twitter/model/token'

Settings.define :emit_type,   :default => "all_but_word", :type => String, :description => 'Type of thing to emit'


Tweet.class_eval do
  def decoded_text
    @decoded_text = text
  end
end

module Wukong
  def self.encode_str str
    str
  end
end

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
      case Settings.emit_type
      when "all_but_word" then
        tweet.retweets     &block
        tweet.replies      &block
        tweet.atsigns      &block
        tweet.hashtags     &block
        tweet.smileys      &block
        tweet.tweet_urls   &block
        tweet.stock_tokens &block
      when "all" then
        tweet.retweets     &block
        tweet.replies      &block
        tweet.atsigns      &block
        tweet.hashtags     &block
        tweet.smileys      &block
        tweet.tweet_urls   &block
        tweet.stock_tokens &block
        tweet.word_tokens  &block
      when "word_only" then
        tweet.word_tokens  &block
      end
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
  :reuse_jvms       => true,
  :io_record_percent => 0.4
  ).run
