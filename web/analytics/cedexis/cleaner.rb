#! /usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'json'

class Mapper < Wukong::Streamer::RecordStreamer

  def recordize str
    return if str.start_with? "autosys_num"
    fields = str.strip.split(",")
    fields if fields.size == 2
  end

  def process code, provider
    clean = provider.strip.gsub(/\s/, '_').gsub(/[^\w\.]/, '').downcase
    yield [ clean ]
  end

end

Wukong::Script.new(Mapper, nil).run
