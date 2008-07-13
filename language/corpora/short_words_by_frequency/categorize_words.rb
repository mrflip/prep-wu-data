#!/usr/bin/env ruby
# -*- coding: mule-utf-8 -*-
require "rubygems"
require "YAML"
require "fastercsv"
require "utils"

FILE_IN_DIRTY_WORDS    = './dirty_words/dirty_words_combined.yaml'
FILE_IN_SCRABBLE_WORDS = './scrabble/twl06.yaml'
# FILE_IN_WORD_FREQS     = './fixd/word_freq_bnc-reduced.csv'
FILE_IN_WORD_FREQS     = './fixd/word_freq_bnc-10k.csv'
#                         head,pos,lemma,freq,disp,freq_sp,freq_wr,tag,head_orig,tag_lemma
BNC_FIELDS_ALL         = [:head, :pos, :lemma, :freq, :disp, :freq_sp, :freq_wr, :tag, :head_orig, :tag_lemma]
BNC_FIELDS_WANT        = [:head, :pos, :lemma, :freq, :tag]

# turns [ {:word => foo, *stuff1}, {:word => bar, *stuff2 }, ...] into { 'foo' => {*stuff}, 'bar' => {*stuff2}, ... }
def mk_word_hash word_list
  word_hash = { }
  word_list.each{ |info| word = info.delete(:word); word_hash[word] = info }
  word_hash
end

word_freqs     = csv_load_words FILE_IN_WORD_FREQS, :lemma, BNC_FIELDS_ALL, BNC_FIELDS_WANT
# puts word_freqs.reject{ |wd,info| (wd.nil?) || (wd.length != 4) || (wd !~ /^[a-z]+$/i) }.to_a[1..100].to_yaml
dirty_words    = mk_word_hash YAML.load(File.open(FILE_IN_DIRTY_WORDS   ))['payload']['word_list']
scrabble_words = mk_word_hash YAML.load(File.open(FILE_IN_SCRABBLE_WORDS))['payload']['word_list']


short_words = scrabble_words.reject{ |wd, info| wd.length != 4 }
short_words.each do |wd, info|
  info.merge! dirty_words[wd]||{}
  info.merge! word_freqs[wd]||{}
end

dump = short_words.sort_by{ |k,v| -(v[:freq]||-1).to_i }.reject{|wd, info| info[:dirt] }.map{ |wd, info| ([wd] + info.values_at(:freq,:head,:pos)).join(', ') }
# dump = { :payload => { :word_list => words_census.sort_by{ |k,v| -v }.map do |k,v| { :word => k, :dirt => v } end } }
YAML.dump(dump, File.open('./fixd/short_words.yaml','w'))
