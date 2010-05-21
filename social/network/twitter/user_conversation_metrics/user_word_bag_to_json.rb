#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'         ; include Wukong
require 'json'


# UserAndGlobalTokStats = FOREACH UserAndGlobalTokStats_1 GENERATE
#   GlobalTokStats::tok AS tok,
#   user_id,
#   num_user_tok_usages,
#   tot_user_usages,
#   user_tok_freq * 1000000000.0 AS user_tok_freq_ppb,
#   vocab,
#   tot_tok_usages,
#   range,
#   user_freq_avg,
#   user_freq_stdev,
#   global_freq_avg,
#   global_freq_stdev,
#   dispersion,
#   tok_freq_ppb
#   ;


class Mapper < Wukong::Streamer::RecordStreamer
  def process(tok, user_id,
      num_user_tok_usages, tot_user_usages, user_tok_freq_ppb, vocab,
      tot_tok_usages, range, user_freq_avg, user_freq_stdev, global_freq_avg, global_freq_stdev, dispersion, tok_freq_ppb, &block)
    yield [user_id, vocab, tot_user_usages, tok, user_tok_freq_ppb, tok_freq_ppb ]
  end
end

class Reducer < Wukong::Streamer::AccumulatingReducer
  attr_accessor :user_id, :vocab, :tot_user_usages, :wordbag
  MAX_WORDBAG_SIZE = 100

  def start! user_id, vocab, tot_user_usages, *args
    self.user_id = user_id
    self.vocab   = vocab.to_i
    self.tot_user_usages = tot_user_usages.to_i
    self.wordbag = []
  end

  def accumulate user_id, vocab, tot_user_usages, tok, user_tok_freq_ppb, tok_freq_ppb
    self.wordbag <<  { :tok => tok, :user_freq => user_tok_freq_ppb.to_f, :rel_freq => (user_tok_freq_ppb.to_f / tok_freq_ppb.to_f) }
  end

  def finalize
    wordbag.sort!{|a, b| b[:rel_freq] <=> a[:rel_freq] }
    json_hsh = { "vocab" => vocab, "total_usages" => tot_user_usages, "words" => wordbag[0 ... MAX_WORDBAG_SIZE] }
    yield [ user_id, json_hsh.to_json ]
  end
end

Wukong::Script.new(
  Mapper,
  Reducer
  ).run
