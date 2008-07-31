#!/usr/bin/env ruby
require 'imw/utils'
require 'imw/utils/paths'
require 'imw/workflow/scaffold'
require 'imw/extract'
# require 'fileutils'; include FileUtils::Verbose
require 'YAML'
include IMW

add_path :ripd_root, [:data_root, 'working/ripd']
scaffold_dataset 'weather/ncdc/stations'


#
# Load the US stations file
#
us_stns = YAML.load(File.open(path_to(:fixd, 'ncdc_weather_stations-US.yaml')))

good_stns = []
[2008].each do |year|
  us_stns[1..10000].each do |stn|
    wban = stn[:WBAN_weatherstation_code]
    usaf = stn[:USAF_weatherstation_code]
    file = "#{year}/#{usaf}-#{wban}-#{year}"
    if File.exist?("ripd/noaa/#{file}.gz")
      has_humidity_measurements = `zcat ripd/noaa/#{file}.gz | grep -qi SA && echo 1`
      if has_humidity_measurements.chomp != ''
        (stn[:datafiles]||={})[:year] = file
        good_stns << stn
        puts file
      end
    end
  end
end


YAML.dump(good_stns, File.open(path_to(:fixd, 'ncdc_weather_stations-US-hum.yaml'), "w"))
