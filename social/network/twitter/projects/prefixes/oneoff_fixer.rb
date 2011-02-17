#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'wukong/and_pig'
require 'json'

class Jsonizer < Wukong::Streamer::RecordStreamer
  def process prefix, list, *_
    yield [prefix, jsonize(list)]
  end

  def jsonize pig_bag
    list  = pig_bag.from_pig_bag.sort{|x,y| y.last <=> x.last}.uniq[0...100] # [['bob', 0.2],['sally', 0.1],...]
    list.map!{|x| x.first}                  # [['bob'], ['sally'], ...]
    {:completions => list.flatten}.to_json  # {"completions":["bob", "sally"]}
  end

end

Wukong::Script.new(Jsonizer, nil).run
