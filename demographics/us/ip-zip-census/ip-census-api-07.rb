#!/usr/bin/env ruby
require 'rubygems'
require 'extlib/class'
require 'monkeyshines'
# $: << Subdir[__FILE__,'../utils/json'].expand_path.to_s
require 'wukong'                       ; include Wukong
# require 'tsv_to_json'    ; include TSVtoJSON

# Settings.resolve!
# Settings.json_keys = "screen_name,id,statuses,replies_out,replies_in,account_age"

# The following census file created by doncarlo should be run against this to create the fields listed below:
# census_2000_sf3_zip_us00007.tsv

module IPCensusGenPop
  class Mapper < Wukong::Streamer::RecordStreamer


    def process *line, &block
      # zip code and logical record number are the common keys across census data files
      zip_code, log_rec_num = line[0..1]
      # per capita income (dollars), 1999
      per_capita_inc = line[52]
      # persons below poverty line, percent
      poverty = line[104].to_f/line[103].to_f
      
      yield [zip_code,log_rec_num,per_capita_inc,poverty]
    end
    
  end
  
end

Wukong::Script.new(
  IPCensusGenPop::Mapper,
  nil
  ).run
