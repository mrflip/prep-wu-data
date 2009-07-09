require 'rubygems'
require 'yaml'
require 'fileutils'
AUSTIN_LAT = (30 + 16.0/60)
AUSTIN_LNG = (97 + 44.0/60)
GSOD_DIR   = File.dirname(__FILE__)+"/ripd"
WORK_DIR   = File.dirname(__FILE__)

# 722540 13904 AUSTIN/BERGSTROM              US US TX KAUS  +30179 -097681 +01509
# 012345 78901 34567890123456789012345678901 34 67 90 23456 890123 5678901 345678
# 0         1         2         3         4         5         6         7
class Station < Struct.new(
    :wmo, :wban, :lat, :lng, :austin_dist, :station_name )
  def self.new_from_line line
    wmo          = line[ 0..5]
    wban          = line[ 7..11]
    station_name  = line[13..41]
    lat_lng_str   = line[58..71].to_s
    lat, lng      = get_lat_lng lat_lng_str
    austin_dist   = get_dist(lat, lng)
    new wmo, wban, lat, lng, austin_dist, station_name
  end

  def nearby?
    austin_dist < 1.25
  end

  def dump
    [wmo, wban, "%7.3f"%lat,"%7.3f"%lng, "%7.3f"%austin_dist, station_name].join("\t")
  end

  def stn_id
    wmo+'-'+wban
  end
  def self.get_lat_lng str
    m = /\+(\d+) \-(\d+)/.match(str) or return
    lat,lng = m.captures
    [ lat.to_f/1000.0, lng.to_f/1000.0 ]
  end

  def self.get_dist lat, lng
    Math.sqrt( (lat - AUSTIN_LAT)**2 + (lng - AUSTIN_LNG)**2 )
  end
end
