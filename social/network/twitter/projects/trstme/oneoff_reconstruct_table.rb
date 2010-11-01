#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'json'

ATRANK_TABLE = {}
class PercentileMapper < Wukong::Streamer::RecordStreamer

  def process key, phash, *_
    ATRANK_TABLE[key.to_f] = onebin_from_json(phash)
  end

  def onebin_from_json phash
    JSON.parse(phash).inject({}) do |h, (k,v)|
      h[k.to_f] = v.to_f
      h
    end
  end

  def after_stream *args
    super *args
    File.open("atrank_table.rb", 'wb') do |f|
      f << "ATRANK_TABLE = " + ATRANK_TABLE.inspect
    end
  end
end

Wukong::Script.new(PercentileMapper, nil).run
