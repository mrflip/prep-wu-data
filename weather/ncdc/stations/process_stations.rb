#!/usr/bin/env ruby
require 'imw/utils';       include IMW; IMW.verbose = true
require 'imw/utils/paths'; as_dset __FILE__

#
# Flat-file parse the station
#

raw_stations = FlatFile.new({
    :filepath => [:ripd, 'noaa/ish-history.txt'],
    :skip_head => 17,
    :cartoon  => %q{
      s6    .s5   .s30                           s2.s2.s2.s4  ..ci5   .ci6    .ci5
      USAF   WBAN  STATION NAME                  CTRY  ST CALL  LAT    LON     ELEV(.1M)
      010014 99999 SOERSTOKKEN                   NO NO    ENSO  +59783 +005350 +00500
      999999 94995 UNIVERSITY OF NEBRASKA        US US NE C52A  +40848 -096565 +03624         },
    :fields => %w[
      USAF_weatherstation_code  WBAN_weatherstation_code        station_name
      country_code_wmo          country_code_fips               us_state        ICAO_call_sign
      lat_sign        lat       lng_sign        lng             elev_sign       elev          ]
  })

class ProcessWeatherStations


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
