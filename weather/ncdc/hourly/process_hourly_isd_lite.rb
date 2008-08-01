#!/usr/bin/env ruby
require 'imw/utils'
require 'imw/utils/paths'
require 'imw/workflow/scaffold'
require 'imw/extract'
# require 'fileutils'; include FileUtils::Verbose
require 'YAML'
include IMW
require 'zlib'

#
# Define the input file structure
#
FILES = {
  :ncdc_weather_stations => {
    :cartoon =>
    %q{
         i4  .i2.i2.i2i6    i6    i6    i6    i6    i6    i6    i6    
         1902 12 27 20  -117 -9999  9671   320    21     8 -9999 -9999
    },
    :skip_head => 17,
    :fields => %w[
        obs_yr obs_mo obs_dy 
	air_temperature 	dew_point_temperature   sea_level_pressure
	wind_direction  	wind_speed_rate         sky_condition_total_coverage_code
	rain_depth_one_hour 	rain_depth_six_hour
    ],
    :null_placeholders => [
      '', '', '',
      '-9999',                  '-9999',                '-9999',                  
      '-9999',                  '-9999',                '-9999',                  
      '-9999',                  '-9999',
    ],
  }
}
FILES[:ncdc_weather_stations_test] =
  FILES[:ncdc_weather_stations].merge({:filepath => [:temp, 'noaa/ish-history-short.txt']})

class ProcessWeatherStations
  #
  # set up the workflow paths
  #
  def config
    # workflow paths
    add_path :ripd_root, [:data_root, 'working/ripd']
    scaffold_dataset 'weather/ncdc/stations'
    scaffold_rip_dir 'ftp.ncdc.noaa.gov/pub/data'
  end

  #
  # process the files
  #
  def parse file_cfg, outp_file
    file_cfg[:file] = File.open(path_to(file_cfg[:filepath]))
    stns = WeatherStationFile.new file_cfg
    stns.skip_lines file_cfg[:skip_head]
    File.open(path_to(outp_file), "w") do |f|
      YAML.dump(stns.records, f)
    end
  end
  
end

processor = ProcessWeatherStations.new
processor.config
# file = :ncdc_weather_stations_test
file = :ncdc_weather_stations
processor.parse FILES[file], [:fixd, file.to_s+'.yaml']
