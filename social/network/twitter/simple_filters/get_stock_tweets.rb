#!/usr/bin/env ruby
require 'rubygems'
require 'extlib/class'
require 'wukong'                       ; include Wukong
require 'wuclan/twitter'               ; include Wuclan::Twitter::Model
require 'wuclan/twitter/model/token'

module StockTweets
  class Mapper < Wukong::Streamer::StructStreamer
 
     #
     #  This separates tweets with stock symbols which have started using the convention of:
     #     $SYMBOL or just $$ to talk about money related things
     #  The website StockTwits http://stocktwits.com has built its website and tools around this convention.
     #
     def process obj, *_, &block
       return unless (obj.is_a?(Tweet) || obj.is_a?(SearchTweet))
       if obj.text =~ /\$\$+|\$[a-zA-Z\:\^\.\_]+/
         obj.text.scan(/\$\$+|\$[a-zA-Z\:\^\.\_]+/).each do |stock_symbol|
           yield ['stock_tweet',stock_symbol,obj.text]
         end
       end
     end
     
  end
end

# Execute the script
Wukong::Script.new(
  StockTweets::Mapper,
  nil
).run
