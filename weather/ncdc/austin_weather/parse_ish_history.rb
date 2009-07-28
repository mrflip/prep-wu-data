#!/usr/bin/env ruby
$: << File.dirname(__FILE__)
require 'weather_main'

File.open(RAWD_DIR+'/ish-history.tsv', "w") do |station_info_file|
  File.open(GSOD_DIR + "/ish-history.txt") do |infile|
    20.times{ infile.readline }
    infile.each do |line|
      line.chomp!
      station = Station.new_from_line line
      station_info_file << station.dump+"\n"
    end
  end
end
