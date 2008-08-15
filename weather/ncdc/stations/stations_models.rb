require 'imw/dataset/datamapper'
require 'imw/dataset/file_collection'

#DataMapper::Logger.new(STDOUT, :debug)
IMW::DataSet.setup_remote_connection IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_weather_ncdc' })

class WeatherStationFile < FlatFile
  property :USAF_weatherstation_code,           Integer,                :key => true
  property :WBAN_weatherstation_code,           Integer,                :key => true
  property :country_code_wmo,                   String, :length => 2,   :index => :cc_wmo
  property :country_code_fips,                  String, :length => 2,   :index => :cc_st
  property :us_state,                           String, :length => 2,   :index => :cc_st
  property :ICAO_call_sign,                     String, :length => 4
  property :lat,                                Float
  property :long,                               Float
  property :elev,                               Float

  def fix_coords sgn, value, scale = 1
    return nil if value == "99999"
    (sgn=="+" ? 1 : -1) * (value.to_f) / scale
  end

  def self.from_raw raw_wstn
    self.create({
        :USAF_weatherstation_code    => raw_wstn[:USAF_weatherstation_code].to_i,
        :WBAN_weatherstation_code    => raw_wstn[:WBAN_weatherstation_code].to_i,
        :country_code_wmo            => raw_wstn[:country_code_wmo].rstrip,
        :country_code_fips           => raw_wstn[:country_code_fips].rstrip,
        :us_state                    => raw_wstn[:us_state].rstrip,
        :ICAO_call_sign              => raw_wstn[:ICAO_call_sign].rstrip,
        :lat                         => fix_coords(raw_wstn[:lat_sign],  raw_wstn[:lat],  1000),
        :long                        => fix_coords(raw_wstn[:lng_sign],  raw_wstn[:lng],  1000),
        :elev                        => fix_coords(raw_wstn[:elev_sign], raw_wstn[:elev],   10),
      })
  end
end
