#!/usr/bin/env ruby
require 'rubygems'
require 'extlib/class'
require 'wukong'                       ; include Wukong
require '../utils/json/tsv_to_json'    ; include TSVtoJSON

Settings.resolve!
Settings.json_keys = "screen_name,id,statuses,replies_out,replies_in,scraped_at,created_at"

module ReplyMetricsJSON
  class Mapper < Wukong::Streamer::StructStreamer


    def process screen_name, id, statuses, replies_out, replies_in, scraped_at, created_at, *_, &block
      row = [screen_name,id,statuses,replies_out,replies_in,scraped_at,created_at]
      yield [screen_name, id, TSVtoJSON::into_json(row)].flatten
    end
    
  end
  
end

Wukong::Script.new(
  ReplyMetricsJSON::Mapper,
  nil
  ).run
