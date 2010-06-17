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
# census_2000_sf3_zip_us00003.tsv

module IPCensusGenPop
  class Mapper < Wukong::Streamer::RecordStreamer


    def process *line, &block
      # zip code and logical record number are the common keys across census data files
      zip_code, log_rec_num = line[0..1]
      # high school graduates, percent (25 years old and over)
      hs_grad = (line[218].to_f + line[235].to_f)/line[208].to_f
      # bachelor's degree or higher, percent
      bs_grad = (line[218].to_f + line[235].to_f)/line[208].to_f
      # mean travel time to work (minutes), workers age 16 and over
      commute = (line[95].to_f*2.0 + line[96].to_f*7.0 + line[97].to_f*12.0 + line[98].to_f*17.0 + line[99].to_f*22.0 
        + line[100].to_f*27.0 + line[101].to_f*32.0 + line[102].to_f*37.0 + line[103].to_f*42.0 + line[104].to_f*52.0 
        + line[105].to_f*75.0 + line[106].to_f*90.0)/line[94].to_f
      
      yield [zip_code,log_rec_num,hs_grad,bs_grad,commute]
    end
    
  end
  
end

Wukong::Script.new(
  IPCensusGenPop::Mapper,
  nil
  ).run
