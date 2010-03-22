#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'wuclan/myspace/model'
include Wuclan::Myspace::Model
include Wuclan::Myspace::Model::RawEntryCategoryToModel

module WordCount
  class Mapper < Wukong::Streamer::StructStreamer
    
    # Words to ignore
    IGNORED_WORDS = Set.new(['the', 'and'])

    # Min number of letters to count word
    MIN_LETTERS = 3
    
    #
    # Split a string into its constituent words.
    #
    # This is pretty simpleminded:
    # * downcase the word
    # * Split at any non-alphanumeric boundary, including '_'
    # * However, preserve the special cases of 's or 't at the end of a
    #   word.
    #
    #   tokenize("Jim's dawg won't hunt: dawg_hunt error #3007a4")
    #   # => ["jim's", "dawd", "won't", "hunt", "dawg", "hunt", "error", "3007a4"]
    #
    def tokenize str
      return [] unless str
      str = str.downcase;
      # kill off all punctuation except [stuff]'s or [stuff]'t
      # this includes hyphens (words are split)
      str = str.
        gsub(/[^a-zA-Z0-9\']+/, ' ').
        gsub(/(\w)\'([st])\b/, '\1!\2').gsub(/\'/, ' ').gsub(/!/, "'")
      # Busticate at whitespace
      words = str.strip.split(/\s+/)
      words.reject!{|w| w.blank? }
      words
    end

    def hour_of obj
      # 20100225060002
      return unless obj.created_at
      obj.created_at[0..9]
    end

    #
    # Emit each word in each line.
    #
    def process *objs
      obj = objs.first
      text = obj.respond_to?(:object_title) ? obj.object_title : obj.text
      tokenize(text).each do |word|
        yield [hour_of(obj), word, 1] if word.length >= MIN_LETTERS && !IGNORED_WORDS.include?(word)
      end
    end
  end

  class Reducer < Wukong::Streamer::AccumulatingReducer

    # Min number of occurrences of word required to emit it
    MIN_COUNT = 2
    
    attr_accessor :date, :word_counts
    def start!(*args)
      self.date = args.first
      self.word_counts = Hash.new(0)
    end
    
    def accumulate(*args)
      # date, word, 1
      self.word_counts[args[1]] += 1
    end
    
    def finalize
      self.word_counts.keys.sort.each do |word|
        count = self.word_counts[word]
        yield [ self.date,  word, count] if count >= MIN_COUNT
      end
    end
  end
end

# Execute the script
Wukong::Script.new(
  WordCount::Mapper,
  WordCount::Reducer
  ).run


