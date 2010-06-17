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
# census_2000_sf3_zip_us00001.tsv

module IPCensusGenPop
  class Mapper < Wukong::Streamer::RecordStreamer


    def process *line, &block
      # zip code and logical record number are the common keys across census data files
      zip_code, log_rec_num = line[0..1]
      # total population.  will be used to find percents
      tot_pop = line[2]
      # persons under 5 years old, percent
      under_5 = (line[40..44].inject(0){|sum,male_age_n| sum + male_age_n.to_i} + line[79..83].inject(0){|sum,female_age_n| sum + female_age_n.to_i}).to_f/tot_pop.to_f
      # persons under 18 years old, percent
      under_18 = (line[40..57].inject(0){|sum,male_age_n| sum + male_age_n.to_i} + line[79..96].inject(0){|sum,female_age_n| sum + female_age_n.to_i}).to_f/tot_pop.to_f
      # persons 65 years and older, percent
      65_over = (line[72..77].inject(0){|sum,male_age_n| sum + male_age_n.to_i} + line[111..116].inject(0){|sum,female_age_n| sum + female_age_n.to_i}).to_f/tot_pop.to_f
      # female persons, percent
      female = line[78].to_f/tot_pop.to_f
      # white persons, percent
      white = line[14].to_f/tot_pop.to_f
      # black persons, percent
      black = line[15].to_f/tot_pop.to_f
      # american indian and alaska native persons, percent
      amin_aknat = line[16].to_f/tot_pop.to_f
      # asian persons, percent
      asian = line[17].to_f/tot_pop.to_f
      # native hawaiian and other pacific islander, percent
      nathaw_pacisl = line[18].to_f/tot_pop.to_f 
      # persons reporting 2 or more races, percent
      two_races = line[20].to_f/tot_pop.to_f
      # persons of hispanic or latino origin, percent
      hispanic = line[30].to_f/tot_pop.to_f
      
      # households
      households = line[144]
      # persons per household
      pphousehold = line[118].to_f/households.to_f
      
      yield [zip_code,log_rec_num,under_5,under_18,65_over,female,white,black,amin_aknat,asian,nathaw_pacisl,two_races,hispanic,households,pphousehold]
    end
    
  end
  
end

Wukong::Script.new(
  IPCensusGenPop::Mapper,
  nil
  ).run
