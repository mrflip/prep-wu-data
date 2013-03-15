#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# require "encoding/character/utf-8"
require 'rubygems'
require 'JSON'
require 'YAML'

src_files = %w[
  dirty_words-adambair-fu_fu.yaml
  dirty_words-alternative_dictionaries-english.yaml
  dirty_words-aol_chat_rooms.yaml
  dirty_words-carlin_seven_words_cant_say.yaml
  dirty_words-cpan-regex_profanity_us.yaml
  dirty_words-from_all_over.yaml
  dirty_words-gareth_moehr_censored_words.yaml
  dirty_words-joshbuddy-swearjar.yaml
  dirty_words-nfl_jerseys.yaml
  dirty_words-reveal.yaml
  dirty_words-scrabble_ospd2.yaml
  dirty_words-tjhanley_profanalyzer.yaml
  dirty_words-whomwah-language-timothy.yaml
]

def get_payload(icss)
  icss.first['dataset']['payload']
end

NONTEXT_CHARS = /[^a-zA-Z0-9\'\s\-\@\$]+/

def tok(elt)
  word = elt['word']
  if (word.chars.count{|ch| ch =~ NONTEXT_CHARS } > 2) then p word ; return nil ; end
  word.
    gsub(NONTEXT_CHARS,'').
    downcase
end

wordlists    = { };
tok_lists    = { }
words_census = Hash.new{|hsh,key| hsh[key] = 0 }

src_files.each do |filename|
  $stderr.puts(filename)
  src_tag  = filename.gsub(/\..*$/, '')
  raw_yaml = YAML.load(File.open(File.join('rawd', filename)))
  wls = get_payload(raw_yaml).map{|wl| wl['blacklist'] }.compact

  wls.each_with_index do |wl, i|
    tag = src_tag + '_' + i.to_s
    wl.reject!{|wd| ['cult', 'occult', 'drug', 'hate'].include? wd['category']}
    wordlists[tag] = wl if wl
    tok_lists[tag] = wl.map{|elt| tok(elt) }.flatten.compact.uniq
  end
end

#
# Count occurrences across lists
#
tok_lists.each do |tag, tl|
  tl.each do |word|
    words_census[word] += 1
  end
end


whitelist = [
  'arvo', 'baltic', 'bob', 'brown', 'buddy', 'chief', 'eddress', 'fish', 'have',
  'quad', 'chicken hawk', ]

words_census.reject! do |wd, count|
  whitelist.include?(wd) || (wd.length <= 2)
end

dump = {
  'payload' => {
    'word_list' => words_census.sort_by{|wd, count| [-count, wd] }.map{|wd,count| { "word" => wd, "weight" => count, } }
  }
}
YAML.dump(dump, File.open('./fixd/dirty_words_combined.yaml','w'))
