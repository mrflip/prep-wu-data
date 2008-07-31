#!/usr/bin/env ruby
require 'imw/utils'
require 'imw/utils/paths'
require 'imw/workflow/scaffold'
require 'imw/extract'
# require 'fileutils'; include FileUtils::Verbose
require 'YAML'
include IMW

#
# Define the input file structure
#
FILES = {
  :ncdc_weather_stations => {
    :filepath => [:ripd, 'noaa/ish-history.txt'],
    :cartoon =>
    %q{
      s6    .s5   .s30                           s2.s2.s2.s4  ..ci5   .ci6    .ci5
      USAF   WBAN  STATION NAME                  CTRY  ST CALL  LAT    LON     ELEV(.1M)
      010014 99999 SOERSTOKKEN                   NO NO    ENSO  +59783 +005350 +00500
      999999 94995 UNIVERSITY OF NEBRASKA        US US NE C52A  +40848 -096565 +03624
    },
    :skip_head => 17,
    :fields => %w[
      USAF_weatherstation_code   WBAN_weatherstation_code station_name
      country_code_wmo country_code_fips us_state ICAO_call_sign
      lat_sign  lat
      lng_sign  lng
      elev_sign elev
    ]
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
