#!/usr/bin/env ruby
$: << File.dirname(__FILE__)
require 'weather_main'

stations = []
File.open(GSOD_DIR + "/ish-history.txt").each do |line|
  line.chomp!
  if true # line[58..71].to_s =~ /\+([234])... -(0[6789]|1[12])/
    station = Station.new_from_line line
    next unless station.nearby?
    stations << station
  end
end

# run yamlize to generate
station_files = YAML.load(File.open(RAWD_DIR+'/gsod_files.yaml'))
stations.each do |station|
  (station_files[station.stn_id]||[]).each do |station_file|
    # station_file = GSOD_DIR+'/'+station_file
    # dest_file    = WORK_DIR+'/zipd/'+File.basename(station_file)
    # next if File.exists?(dest_file)
    # if ! File.exists?(station_file) then warn "missing: #{station_file}" ; next ; end
    # puts station_file
    # FileUtils.cp station_file, dest_file
    puts station_file
  end
end

File.open(RAWD_DIR+'/station_info.tsv', "w") do |station_info_file|
  stations.sort_by(&:austin_dist).each do |station|
    station_info_file << station.dump+"\n"
  end
end
