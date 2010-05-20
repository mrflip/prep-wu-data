#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'         ; include Wukong
require 'json'

class Mapper < Wukong::Streamer::RecordStreamer
  def process tok, user_id, num_user_tok_usages, tot_user_usages, user_tok_freq, user_tok_freq_sq, vocab, &block
    yield [user_id, vocab, tot_user_usages, tok, user_tok_freq]
  end
end

class Reducer < Wukong::Streamer::AccumulatingReducer
  attr_accessor :user_id, :vocab, :tot_user_usages, :word_bag
  def start! user_id, vocab, tot_user_usages, *args
    self.user_id = user_id
    self.vocab   = vocab
    self.tot_user_usages = tot_user_usages
    self.word_bag = []
  end

  def accumulate user_id, vocab, tot_user_usages, tok, user_tok_freq
    self.word_bag <<  { tok => user_tok_freq.to_f }
  end

  def finalize
    fixed_number_of_words = 100 # max number of words to return
    word_bag.sort!{|x,y| y.values.first <=> x.values.first}
    json_hsh = {"vocab" => vocab.to_i, "total_usages" => tot_user_usages.to_i, "words" => word_bag[0...fixed_number_of_words]}
    yield [ user_id, json_hsh.to_json ]
  end
end

Wukong::Script.new(
  Mapper,
  Reducer
  ).run
