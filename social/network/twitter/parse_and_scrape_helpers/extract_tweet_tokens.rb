#!/usr/bin/env ruby
require 'rubygems'
require 'extlib/class'
require 'wukong'                       ; include Wukong
require 'wuclan/twitter'               ; include Wuclan::Twitter::Model
require 'wuclan/twitter/model/token'

#
# See bundle.sh for running pattern
#

module ExtractTweetTokens
  class Mapper < Wukong::Streamer::StructStreamer
    #
    # Extract semantic info from each object: (well, right now just from tweets):
    #  re-tweets,
    #  replies and atsigns,
    #  hashtags,
    #  smileys,
    #  embedded urls,
    #  etc
    #
    def process tweet, *_, &block
      case tweet
      when Tweet, SearchTweet
        tweet.retweets   &block
        tweet.replies    &block
        tweet.atsigns    &block
        # tweet.hashtags   &block
        # tweet.smileys    &block
        # tweet.tweet_urls &block
      else return
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
  :partition_fields => 2, # rsrc, token
  :sort_fields      => 3,  # rsrc, token, tweet_id
  :reuse_jvms       => true
  ).run

