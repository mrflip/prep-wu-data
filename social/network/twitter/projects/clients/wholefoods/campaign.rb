#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'wukong'                       ; include Wukong
require 'wuclan/twitter'               ; include Wuclan::Twitter::Model
require 'wukong/encoding'


class Mapper < Wukong::Streamer::StructStreamer

  # Keywords: wholefoods?, ndvh, whole foods?

  KEYWORDS = %r{\b(whole\s*foods?|ndvh)\b}

  def process tweet, *_, &block
    return unless tweet.text =~ KEYWORDS
    timestamp = tweet.created_at.to_i / 1_000_000
    return if (timestamp < 20_100_504 || timestamp > 20_100_509)
    yield tweet.to_flat
  end

end

# Execute the script
Wukong::Script.new(
  Mapper,
  nil
  ).run
