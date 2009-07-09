#!/usr/bin/env ruby
$: << File.dirname(__FILE__)
require 'weather_main'

stations = []
File.open(GSOD_DIR + "/ish-history.txt").each do |line|
  line.chomp!
  if line[58..71].to_s =~ /\+(2[89]|3[01])... -0(9[678])/
    station = Station.new_from_line line
    next unless station.nearby?
    stations << station
  end
end

File.open(WORK_DIR+'/station_info.tsv', "w") do |station_info_file|
  stations.sort_by(&:austin_dist).each do |station|
    station_info_file << station.dump+"\n"
  end
end

# run yamlize to generate
station_files = YAML.load(File.open(WORK_DIR+'/gsod_files.yaml'))
stations.each do |station|
  (station_files[station.stn_id]||[]).each do |station_file|
    station_file = GSOD_DIR+'/'+station_file
    dest_file    = WORK_DIR+'/zipd/'+File.basename(station_file)
    next if File.exists?(dest_file)
    if ! File.exists?(station_file) then warn "missing: #{station_file}" ; next ; end
    puts station_file
    FileUtils.cp station_file, dest_file
  end
end
