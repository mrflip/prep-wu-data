#!/usr/bin/env ruby
require 'rubygems'
require 'extlib/class'
require 'wukong'                       ; include Wukong
require 'wuclan/twitter'               ; include Wuclan::Twitter::Model
require 'wuclan/twitter/model/token'

Settings.define :wordlist, :description => "A file with a list of words to use for searching through tweets."

module WordlistTweets
  class Mapper < Wukong::Streamer::StructStreamer
 
     #
     #  This separates tweets that contain words in a word list.
     #
     def process obj, *_, &block
       return unless (obj.is_a?(Tweet) || obj.is_a?(SearchTweet))
       if obj.text =~ word_list_regexp
         obj.text.scan(word_list_regexp).each do |word|
           yield ['wordlist_tweet',word,obj.to_flat].flatten
         end
       end
     end
     
  end
end

def regexp_from_wordlist
  
  words = File.open(Settings.wordlist.to_s)
  word_array = words.read.split(/[\s\,\-\.\/]+/)
  p word_array
  word_regexp = "/\b(" + word_array.flatten.uniq.join("|") + ")\b/"
  puts word_regexp
  
end

regexp_from_wordlist

# Execute the script
Wukong::Script.new(
  StockTweets::Mapper,
  nil
).run
