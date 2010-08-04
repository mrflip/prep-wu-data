#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'wukong'                       ; include Wukong
require 'wuclan/twitter'               ; include Wuclan::Twitter::Model

class TweetBagMapper < Wukong::Streamer::StructStreamer

  def regexp
    return @regexp if @regexp
    if options[:regexp_path]
      @regexp = File.read(File.expand_path(options[:regexp_path]))
    elsif options[:regexp]
      @regexp = options[:regexp]
    end
  end

  def begin_date
    @begin_date ||= options[:begin] || options[:begin_date] || 20060101000000 # Jan 1st, 2006
  end

  def end_date
    @begin_date ||= options[:end] || options[:end_date] || 30000101000000 # In the year 3000...
  end

  def process tweet, *_, &block
    return unless tweet.created_at >= begin_date && tweet.created_at < end_date
    return unless match_data = regexp.match(text.upcase)
    yield [tweet.to_flat, match_data.to_a[1..-1].join(",")]
  end

end

# Execute the script
Wukong::Script.new(
  TweetBagMapper,
  nil
  ).run
