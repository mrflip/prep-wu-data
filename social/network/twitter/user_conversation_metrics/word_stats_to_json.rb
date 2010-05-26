#!/usr/bin/env ruby
require 'rubygems'
require 'monkeyshines'
require 'wukong'         ; include Wukong
$: << Subdir[__FILE__,'../utils/json'].expand_path.to_s
require 'tsv_to_json'    ; include TSVtoJSON

Settings.resolve!
Settings.json_keys = "token,total_usages,range,user_freq_avg,user_freq_stdev,global_freq_avg,global_freq_stdev,dispersion,rel_freq_ppb"

class Mapper < Wukong::Streamer::RecordStreamer
  def process *line, &block
    yield [line[0], TSVtoJSON::into_json(line)].flatten
  end
end

Wukong::Script.new(
  Mapper,
  nil
  ).run
