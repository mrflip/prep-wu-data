#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'wuclan/twitter'               ; include Wuclan::Twitter::Model
require 'wuclan/twitter/model/token'


class Mapper < Wukong::Streamer::StructStreamer

  #ARepliesB
  # :user_a_id,              Integer
  # :user_b_id,              Integer
  # :tweet_id,              Integer
  # :in_reply_to_tweet_id,  Integer

  def process obj, *_, &block
    case obj
    when ARepliesB
      hsh = {:user_a_id => obj.user_a_id.to_i, :user_b_id => obj.user_b_id.to_i, :tweet_id => obj.tweet_id.to_i, :in_reply_to_tweet_id => obj.in_reply_to_tweet_id.to_i}
      yield ARepliesB.from_hash(hsh, true).to_flat
    end
  end
  
end

Wukong::Script.new(
  Mapper,
  nil
  ).run
