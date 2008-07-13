#!/usr/bin/env ruby
# -*- coding: mule-utf-8 -*-
require "rubygems"
require "activesupport"
# require "JSON"
#require "YAML"
require "fastercsv"
require "utils"


OUT_DIR = '/home/flip/ics/fixd/language/text/gutenberg'
#OUT_FILE = "#{OUT_DIR}/gutenberg_word_adjacency.yaml"
#OUT_FILE = "#{OUT_DIR}/short-reduced.yaml"
# OUT_FILE = "#{OUT_DIR}/foo/short.yaml"
OUT_FILE = "#{OUT_DIR}/shakespeare_word_adjacency-reduced.yaml"

class Babbler
  attr_accessor :chains, :idxs, :census
  def initialize(adjacency_file)
    adjacency_info = YAML.load File.open(adjacency_file)
    self.chains, self.idxs, self.census = adjacency_info.values_at('chains', 'idxs', 'census')
    super()
  end

  def sentence_len() gauss_rand(3, 3).to_i end

  def random_word()
    idxs[ idxs.keys.at_random ]
  end

  def make_sentence(min_words, min_chars)
    prev = random_word
    sentence = [prev]
    until ((sentence.length > min_words) && (sentence.to_s.length > min_chars)) do
      idx  = (chains[prev] && chains[prev].at_random) || idxs.at_random
      word = idxs[idx]
      sentence << word
      prev = word
    end
    sentence.join(' ').humanize
  end

end


babbler = Babbler.new(OUT_FILE)
NUM_SENTENCES = 100
NUM_SENTENCES.times do
  puts babbler.make_sentence(3, 15)
end
