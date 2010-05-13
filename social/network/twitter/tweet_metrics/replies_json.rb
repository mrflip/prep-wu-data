#!/usr/bin/env ruby
require 'rubygems'
require 'extlib/class'
require 'wukong'                       ; include Wukong
require '../utils/json/tsv_to_json'    ; include TSVtoJSON

Settings.resolve!
Settings.json_keys = "screen_name,id,statuses,replies_out,replies_in,account_age"

module ReplyMetricsJSON
  class Mapper < Wukong::Streamer::RecordStreamer


    def process *line, &block
      return if line[6].nil?
      created = Time.gm(line[6][0..3].to_i,line[6][4..5].to_i,line[6][6..7].to_i)
      scraped = Time.gm(line[5][0..3].to_i,line[5][4..5].to_i,line[5][6..7].to_i)
      line[5] = ((scraped - created)/(24*60*60)).to_i
      yield [line[0..1], TSVtoJSON::into_json(line)].flatten
    end
    
  end
  
end

Wukong::Script.new(
  ReplyMetricsJSON::Mapper,
  nil
  ).run
