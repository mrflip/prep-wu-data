#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'wukong'                       ; include Wukong
require 'wuclan/twitter'               ; include Wuclan::Twitter::Model

class TweetBagMapper < Wukong::Streamer::StructStreamer

  # def regexp
  #   return @regexp if @regexp
  #   if options[:regexp_path]
  #     @regexp = File.read(File.expand_path(options[:regexp_path]))
  #   elsif options[:regexp]
  #     @regexp = options[:regexp]
  #   end
  # end

  def regexp
    /(BEL+E? *(&(amp;)?|A?ND?|\+)? *S(E|A)BAS+(T|CH)[IEA]+N|ST(U|EW)(ART)? *M(U|E)RDOC(H|K))/i
    # /SHARE[-_\s]*POINT/i
    # /(NIS+AN.*LEAF|LEAF.*NIS+AN|ELECTRIC *(VEHICLE|CAR)|LEAF.*CAR|CAR.*LEAF)/i
  end

  def begin_date
    @begin_date ||= (options[:begin] || options[:begin_date] || 20060101000000).to_i # Jan 1st, 2006
  end

  def end_date
    @end_date ||= (options[:end] || options[:end_date] || 30000101000000).to_i # In the year 3000...
  end

  def process tweet, *_, &block
    return unless tweet.created_at.to_i >= begin_date && tweet.created_at.to_i < end_date
    return unless match_data = regexp.match(tweet.text || '')
    yield [tweet.to_flat, match_data.to_a[1..-1].join(",")]
  end

end

# Execute the script
Wukong::Script.new(
  TweetBagMapper,
  nil
  ).run
