#!/usr/bin/env ruby
require 'imw/utils'
require 'imw/utils/paths'
require 'imw/workflow/scaffold'
require 'fileutils'; include FileUtils::DryRun

include IMW

class ProcessWeatherStations

  def config
    add_path :ripd_root, [:data_root, 'working/ripd']
    scaffold_dataset 'weather/ncdc/stations'
    scaffold_rip_dir 'ftp.ncdc.noaa.gov/pub/data'
    add_path :raw_stations_file, [:ripd, 'data/noaa/ish-history.txt']
    add_path :out_stations_file, [:fixd, 'ncdc_weather_stations.yaml']
  end

  def parse
    File.open(path_to(:raw_stations_file)).readlines[0..5].each do |line|
      puts line.reverse
    end
  end
end

processor = ProcessWeatherStations.new
processor.config
processor.parse
