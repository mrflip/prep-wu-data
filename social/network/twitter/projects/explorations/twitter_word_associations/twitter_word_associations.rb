#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'                       ; include Wukong
require 'wuclan/twitter'               ; include Wuclan::Twitter::Model

module WordAssociations
  class Mapper < Wukong::Streamer::StructStreamer
    #
    # Split a string into its constituent word association pairs
    # of the form X AND Y
    #
    def tokenize str
      return [] unless str
      str = str.downcase;
      # kill off all punctuation except [stuff]'s or [stuff]'t
      # this includes hyphens (words are split)
      str = str.
        gsub(/[^a-zA-Z0-9\']+/, ' ').
        gsub(/(\w)\'([st])\b/, '\1!\2').gsub(/\'/, ' ').gsub(/!/, "'")
      # Look for occurrences of X and Y.
      # FIXME: not smart enough to handle X and Y and Z
      re = /(\w+)\s+and\s+(\w+)/
      words = str.scan(re).map{|w| w.sort}
      words
    end


    def process tweet, *_, &block
      case tweet
      when Tweet, SearchTweet
        tokenize(tweet.text).each{|pair| yield pair}
      else return
      end
    end

  end

  require 'wukong/streamer/count_keys'
  class Reducer < Wukong::Streamer::CountKeys
  end

end

# Execute the script
Wukong::Script.new(
  WordAssociations::Mapper,
  WordAssociations::Reducer,
  :num_key_fields => 2
  ).run
