#!/usr/bin/env ruby
$: << File.dirname(__FILE__)
require 'weather_main'

# First run:
# time ( ls -U1R ripd/  | egrep '.gz$' > rawd/gsod_files.txt )

file_listing = { }
f = File.open(GSOD_DIR+'/gsod_files.txt')
f.readlines.each do |filename|
  filename.chomp!
  filename =~ /(\d+)-(\d+)-(\d+)\..*gz$/; wmo,wban,year = [$1,$2,$3]
  puts filename unless wmo && wban && year
  stn_id = wmo+'-'+wban
  file_listing[stn_id] ||= []
  file_listing[stn_id] << "#{year}/#{filename}"
end
File.open(GSOD_DIR+'/gsod_files.yaml', "w") do |station_listing_file|
  station_listing_file << YAML.dump(file_listing)
end
