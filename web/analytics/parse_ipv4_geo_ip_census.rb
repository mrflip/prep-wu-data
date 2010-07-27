#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require File.dirname(__FILE__)+'/geo_ip_census' ; include GeoIPCensus

HOLD_FIELDS = ["start_ip", "end_ip"]

class Mapper < Wukong::Streamer::LineStreamer
  def process line, &blk
    fields = line.strip.gsub(/\"/, "").split("\t") rescue []
    RawIPCensus.new(*fields).yield_records(&blk)
  end
end

class Reducer < Wukong::Streamer::AccumulatingReducer
  attr_accessor :record

  def get_key ip_key, *args
    ip_key
  end
  
  def start! ip_key, *args
    @record = {}
    @record[:census_data] = []
  end

  def accumulate ip_key, *args
    @record[:census_data] << [args.first.to_i, RawIPCensus.new(*args[1..-1]).to_hash.reject{|k,v| HOLD_FIELDS.include?(k) }.compact_blank]
  end

  def finalize
    yield [key, record.to_json]
  end
  
end

Wukong::Script.new(Mapper, Reducer).run
