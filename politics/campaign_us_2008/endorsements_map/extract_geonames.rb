#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'iconv'; $KCODE = 'u'
require 'rubygems'
require 'yaml'
require 'json'
require 'imw'; include IMW; IMW.log.level = Logger::DEBUG
#
require 'lib/geolocation'
require 'lib/struct_dumper'

# You have to download, then unzip
#  http://download.geonames.org/export/dump/cities15000.zip -- for smaller cities use cities1000.zip
GEONAMES_CITIES_FILE = 'ripd/download.geonames.org/export/dump/cities1000.txt' # '/tmp/foo.txt' #
#
# geonameid     u_name  name    altnm   lat     lng     f_cl    f_code  cc      cc2     admin1  admin2  admin3  admin4  pop     elev    gtopo30 timezone        modification_date
# 4099296       Alma    Alma            35.4778 -94.221 P       PPL     US              AR      033                     4474    132     133     America/Chicago 2006-01-17
# 0             1       2       3       4       5       6       7       8       9       10      11      12      13      14      15      16      17              18
#

# ---------------------------------------------------------------------------

announce Time.now.to_s+" Loading raw file"
Geolocation.all = { }
#
File.open(GEONAMES_CITIES_FILE).readlines.each do |line|
  track_count :lines
  fields = line.chomp.split("\t")
  next unless fields[8] == 'US'
  geo = Geolocation.add(fields[0], fields[2], *fields[4..-1])
end

# Save
Geolocation.dump
puts Geolocation['IL', 'Springfield'].to_json
# Check
Geolocation.load
puts Geolocation['IL', 'Springfield'].to_json

