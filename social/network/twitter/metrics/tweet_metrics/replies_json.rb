#!/usr/bin/env ruby
require 'rubygems'
require 'extlib/class'
require 'monkeyshines'
$: << Subdir[__FILE__,'../utils/json'].expand_path.to_s
require 'wukong'                       ; include Wukong
require 'tsv_to_json'    ; include TSVtoJSON

Settings.resolve!
Settings.json_keys = "screen_name,id,statuses,replies_out,replies_in,account_age"

module ReplyMetricsJSON
  class Mapper < Wukong::Streamer::RecordStreamer


    def process *line, &block
      return if line[6].nil?
      created = Time.gm(line[6][0..3].to_i,line[6][4..5].to_i,line[6][6..7].to_i)
      scraped = Time.gm(line[5][0..3].to_i,line[5][4..5].to_i,line[5][6..7].to_i)
      line[5] = ((scraped - created)/(24*60*60)).to_i
      line[1] = line[1].to_i
      line[2] = line[2].to_i
      line[3] = line[3].to_i
      line[4] = line[4].to_i
      yield [line[0..1], TSVtoJSON::into_json(line)].flatten
    end
    
  end
  
end

Wukong::Script.new(
  ReplyMetricsJSON::Mapper,
  nil
  ).run
