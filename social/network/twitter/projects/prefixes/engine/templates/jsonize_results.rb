#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'wukong/and_pig'
require 'json'

Settings.define :num_elements, :required => true, :type => Integer, :description => "The number of screen names to return"

class Jsonizer < Wukong::Streamer::RecordStreamer
  def process prefix, list, *_
    yield [prefix, sort_and_jsonize(list)]
  end

  def sort_and_jsonize pig_bag
    list  = pig_bag.from_pig_bag.sort{|x,y| x.last <=> y.last}.uniq[0...Settings.num_elements]
    list.map!{|x| x.first}
    {:completions => list}.to_json
  end
  
end

Wukong::Script.new(Jsonizer, nil).run
