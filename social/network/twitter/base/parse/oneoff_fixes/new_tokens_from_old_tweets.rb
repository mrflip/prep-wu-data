#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'wuclan/twitter' ; include Wuclan::Twitter
require 'wuclan/twitter/token'
require 'wuclan/twitter/a_relationships_b'

#
# 20101006 - we changed the token models, esp. a_atsigns_b
# and need to run the multigraph script. This makes
# sure we're using a uniform set of relationship tokens to
# do so. It has the additional side effect of reparsing
# out the old tokens using the new regexps etc. just to be
# sure.
#
class TokenParser < Wukong::Streamer::StructStreamer

  def process tweet, *_
    [tweet.atsigns, tweet.tweet_urls, tweet.hashtags, tweet.stock_tokens, tweet.smileys].flatten.compact.each do |tok|
      yield tok
    end
  end

end

Wukong::Script.new(TokenParser, nil).run
