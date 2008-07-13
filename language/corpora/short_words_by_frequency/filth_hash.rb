#!/usr/bin/env ruby
# -*- coding: mule-utf-8 -*-
require "rubygems"
require "JSON"
require "YAML"
require "fastercsv"
require "utils"

dirty_words = YAML.load(File.open("dirty_words/dirty_words_combined.yaml"))
dirty_words = dirty_words["payload"]["word_list"]

MAX_FILTH_LEN = 4

filth = dirty_words.map{|info| [info[:word][0..MAX_FILTH_LEN-1], info[:word]] }.uniq

puts filth.sort.map{ |wd| wd.to_json }

#stems = filth.sort_by{|wd| [wd.length, wd]}.map{|wd| wd}
#puts stems.join('|'), filth.length
# .reverse
