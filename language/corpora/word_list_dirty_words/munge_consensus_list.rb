#!/usr/bin/env ruby
# -*- coding: mule-utf-8 -*-
require 'iconv'
# require "encoding/character/utf-8"
require 'rubygems'
require 'JSON'
require 'YAML'
require 'oniguruma'
# require 'UniversalDetector'
# $KCODE = 'UTF8'
# require 'ya2yaml'
include Oniguruma


src_files = %w[
  aol_banned_words.yaml
  carlin_seven_words_cant_say.yaml
  gareth_moehr_censored_words.yaml
  more.yaml
  reveal_questionable_words.yaml
  scrabble_ospd2_obscene.yaml
  alternative_dictionaries_english_indecent_word_list.yaml
]

def get_payload(icss)
  icss['infochimps_dataset']['payload']
end

def tok(elt)
  elt['word'].gsub(/\W+/,'').downcase
end

wordlists    = { }; tok_lists = { }
words_census = { }
words_hook3  = { }
src_files.each do |src_file|
  src_tag = src_file.gsub(/_.*$/,'')
  wls = get_payload( YAML.load(File.open(src_file)) ).map{ |wl| wl['word_list'] }.compact
  wls.each_with_index do |wl, i|
    tag = src_tag + '_' + i.to_s
    wl.reject!{ |wd| ['cult', 'occult', 'drug', 'hate'].include? wd['category']}
    wordlists[tag] = wl if wl
    tok_lists[tag] = wl.map{ |elt| tok(elt) }
  end
end

tok_lists.each do |tag, tl|
  tl.each do |word|
    words_census[word]  ||= 0; words_census[word] += 1
    hook3 = word[0..3]
    words_hook3[hook3] ||= []; words_hook3[hook3] << word
  end
  #puts [ src_file, wl.length , wl[0..10].map{ |elt| elt['word'] } ].to_json.to_s
end


whitelist = %w[
arvo baltic bob brown buddy chief eddress fish have quad
] + ['chicken hawk', ]



# wordlists['scrabble_0'].each do |elt|
#   words_census.delete tok(elt)
# end

#words_census.reject!{ |wd, count| tok_lists['scrabble_0'].include?(wd) }
words_census.reject! do |wd, count|
    whitelist.include?(wd) # ||
    # (wd.length > 4) ||
    # tok_lists['scrabble_0'].include?(wd) ||
    # false
end

dump = { 'payload' => { 'word_list' => words_census.sort_by{ |k,v| -v }.map do |k,v| { :word => k, :dirt => v } end } }
YAML.dump(dump, File.open('./fixd/dirty_words_combined.yaml','w'))

# puts words_census.sort_by{ |k,v| k }.map{|k,v| k }.to_json
# puts words_hook3.sort_by{  |k,v| v.length }.to_json
