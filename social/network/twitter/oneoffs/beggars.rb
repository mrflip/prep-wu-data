#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'                       ; include Wukong
require 'wuclan/twitter'               ; include Wuclan::Twitter::Model
require 'wukong/encoding'


class GrepMapper < Wukong::Streamer::StructStreamer

  # Keywords: Sigur Ros, Sigur Rós, Jónsi, Jonsi, iamjonsi, TheNewPornos, Neko Case, Destroyer, New Pornographers
  # keywords = "Sigur Ros, Sigur Rós, Jónsi, Jonsi, iamjonsi, TheNewPornos, Neko Case, Destroyer, New Pornographers"
  
  KEYWORDS = %r{\b((Sigur\sRos)|(Sigur\sR\ws)|(J\wnsi)|(Jonsi)|(iamjonsi)|(TheNewPornos)|(Neko\sCase)|(Destroyer)|(New\sPornographers))\b}

  def process tweet, *_, &block
    return unless tweet.text =~ KEYWORDS
    keys = tweet.text.scan(KEYWORDS).join(",")
    yield [tweet.id, tweet.created_at, tweet.twitter_user_id, tweet.favorited, tweet.truncated, tweet.in_reply_to_user_id, tweet.in_reply_to_status_id, tweet.text, tweet.source, tweet.in_reply_to_screen_name, ]
  end
end

# Execute the script
Wukong::Script.new(
  GrepMapper,
  nil
  ).run