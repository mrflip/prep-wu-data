#!/usr/bin/env ruby
$: << ENV['WUKONG_DIR']
require 'wukong'

module NcdcWeather

  class WeatherDay < Struct.new(
      :stn, :wban, :date,
      :temp, :temp_ct, :dewp, :dewp_ct, :slp, :slp_ct,
      :stp, :stp_ct, :visib, :visib_ct, :wdsp, :wdsp_ct,
      :mxspd, :gust,
      :max_temp, :max_temp_flag,
      :min_temp, :min_temp_flag,
      :precip, :precip_flag,
      :snow_depth,
      :fog, :rain_or_drizzle, :snow_or_ice, :hail, :thunder, :tornado)

    def self.new_from_line line
      stn, wban, date, temp, temp_ct, dewp, dewp_ct, slp, slp_ct, stp, stp_ct, visib, visib_ct, wdsp, wdsp_ct, mxspd, gust, max_temp_and_flag, min_temp_and_flag, precip_and_flag, snow_depth, frshtt = line.split(/\s+/)
      max_temp = max_temp_and_flag.gsub(/(\*)$/,"");    max_temp_flag = $1
      min_temp = min_temp_and_flag.gsub(/(\*)$/,"");    min_temp_flag = $1
      precip   =   precip_and_flag.gsub(/([A-I])$/,""); precip_flag   = $1
      fog, rain_or_drizzle, snow_or_ice, hail, thunder, tornado = frshtt.chars
      station = new(stn, wban, date, temp, temp_ct, dewp, dewp_ct, slp, slp_ct, stp, stp_ct, visib, visib_ct, wdsp, wdsp_ct, mxspd, gust, max_temp, max_temp_flag, min_temp, min_temp_flag, precip, precip_flag, snow_depth, fog, rain_or_drizzle, snow_or_ice, hail, thunder, tornado)
      station.invalid_to_null!
      station
    end

    def invalid_to_null!
      self.temp       = '\N' if temp       == '9999.9'
      self.dewp       = '\N' if dewp       == '9999.9'
      self.slp        = '\N' if slp        == '9999.9'
      self.stp        = '\N' if stp        == '9999.9'
      self.visib      = '\N' if visib      ==  '999.9'
      self.wdsp       = '\N' if wdsp       ==  '999.9'
      self.mxspd      = '\N' if mxspd      ==  '999.9'
      self.gust       = '\N' if gust       ==  '999.9'
      self.max_temp   = '\N' if max_temp   == '9999.9'
      self.min_temp   = '\N' if min_temp   == '9999.9'
      self.precip     = '\N' if precip     ==  '99.99'
      self.snow_depth = '\N' if snow_depth ==  '999.9'
    end
  end

  class Mapper < Wukong::Streamer::LineStreamer
    #
    # Emit each word in each line.
    #
    def process line
      return if line =~ /^STN--- WBAN/
      wd = WeatherDay.new_from_line line
      yield wd
    end
  end

  # Execute the script
  Wukong::Script.new(
    Mapper,
    nil
    ).run
end

