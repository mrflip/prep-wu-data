require 'rubygems'
require 'yaml'
require 'fileutils'
AUSTIN_LAT =  (30 + 16.0/60)
AUSTIN_LNG = -(97 + 44.0/60)
GSOD_DIR   = File.dirname(__FILE__)+"/ripd"
ISH_DIR    = File.dirname(__FILE__)+"/ish"
RAWD_DIR   = File.dirname(__FILE__)+"/rawd"
WORK_DIR   = File.dirname(__FILE__)

# 722540 13904 AUSTIN/BERGSTROM              US US TX KAUS  +30179 -097681 +01509
# 012345 78901 34567890123456789012345678901 34 67 90 23456 890123 5678901 345678
# 0         1         2         3         4         5         6         7
class Station < Struct.new(
    :wmo, :wban, :lat, :lng, :elev, :ct_wmo, :ct_fips, :st, :icao, :station_name, :austin_dist )
  def self.new_from_line line
    wmo           = line[ 0..5]
    wban          = line[ 7..11]
    station_name  = line[13..41].strip      #
    ct_wmo        = line[43..44]
    ct_fips       = line[46..47]
    st            = line[49..50].strip
    icao          = line[52..56].strip
    lat_lng_str   = line[58..71].to_s
    lat, lng      = get_lat_lng lat_lng_str
    elev_sgn      = line[73..73]
    elev          = 0.1*line[74..78].to_i * ( elev_sgn == '+' ? 1 : -1 )
    austin_dist   = get_dist(lat, lng)
    new wmo, wban, lat, lng, elev, ct_wmo, ct_fips, st, icao, station_name, austin_dist
  end

  def nearby?
    austin_dist < 5
  end

  def dump
    # "%7.3f"%austin_dist,
    [wmo, wban, "%7.3f"%lat,"%7.3f"%lng,"%7.3f"%elev, ct_wmo, ct_fips, st, icao, station_name, austin_dist].join("\t")
  end

  def stn_id
    wmo+'-'+wban
  end
  def self.get_lat_lng str
    m = /([\+\-])(\d+) ([\+\-])(\d+)/.match(str) or return [999, 999]
    lat_sgn, lat, lng_sgn, lng = m.captures
    lat_sgn = (lat_sgn=='+' ? 1 : -1 )
    lng_sgn = (lng_sgn=='+' ? 1 : -1 )
    [ lat_sgn * lat.to_f/1000.0, lng_sgn * lng.to_f/1000.0 ]
  end

  def self.get_dist lat, lng
    if (lat.to_i == 999) || (lng.to_i == 999) then return -1 end
    Math.sqrt( (lat - AUSTIN_LAT)**2 + (lng - AUSTIN_LNG)**2 ) rescue -1
  end
end
