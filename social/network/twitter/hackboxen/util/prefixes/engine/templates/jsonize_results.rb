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
    list  = pig_bag.from_pig_bag # will be an array of arrays
    {:completions => list.flatten}.to_json
  end

end

Wukong::Script.new(Jsonizer, nil).run
