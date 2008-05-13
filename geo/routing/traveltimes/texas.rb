#!/usr/bin/env ruby
# Setup environmend
$:.unshift ENV['HOME']+'/ics/code/lib/ruby/lib' # find infinite monkeywrench lib
require 'imw.rb'
require 'traversal'

# 
# for 10 mostly-equal scripts run as 
# ./texas.rb | split -l 25000 -d -a3 --verbose - rawd/dumpers/texas_chunk_

#
# Fetcher setup
# 
$wget='wget -nv'
$url_mileage_do = 'http://ecpa.cpa.state.tx.us/mileage/mileage.do'
$session        = '%3Bjsessionid%3D0000T4yA90QQu6F1hmTLNO8UPct%3A-1'
$referer        = 'http://ecpa.cpa.state.tx.us/mileage/Mileage.jsp'
$post_data      = 'city1=%s&state1=%s&city2=%s&state2=%s&city3=%s&state3=%s&city4=%s&state4=%s&city5=%s&state5=%s&city6=%s&state6=%s&city7=%s&state7=%s&city8=%s&state8=%s&city9=%s&state9=%s&rate=.500&action=Calculate'
$out_dir        = './rawd/dump/texas'
$out_file_base  = 'texas'
$out_file_ext   = 'html'
# How many can we ask for each time?
$segs_n         = 9  
# list of cities
$cities_file    = './rawd/www.window.state.tx.us/comptrol/cities.txt'


#
# Lay out journeys
def get_journeys(cities, segs_n)
  trip_segs      = trip_segments(cities.length-1, segs_n)
  trip_segs.each{|seg| puts seg.to_json}
  trip_journeys  = trip_segs.map{|stops| cities.values_at(*stops) }
end

#
# Make commands to fetch each journey
def journeys_dump_wgets(cities, segs_n)
  # the segments of our trip
  journeys = trip_segments(cities.length-1, segs_n)
  # all the edges we need to visit
  edges      = all_ordered_pairs(segs_n)
  trip_left  = Hash.zip(edges, [false]*edges.length)

  # setup lines
  (0..((cities.length/10).to_i)).each{ |dir| puts "mkdir -p %s/%03d" % [ $out_dir, dir ] }

  # batch submit each trip
  journeys.each do |journey|
    # city names for each stop (pad with ""'s)
    padding        = [ ['',''] ]*(segs_n+1)
    stop_names     = (cities.values_at(*journey) + padding).slice(0..segs_n-1)
    
    # set up us the command
    this_post_data = $post_data % stop_names.flatten
    this_out_file  = "%s/%03d/%s-%s.%s" % [ $out_dir, (journey[0]/10).to_i, $out_file_base, journey.join('_'), $out_file_ext ]
    this_command   = %q{%s "%s%s" -O %s --referer="%s" --post-data="%s"} % [$wget, $url_mileage_do, $session, this_out_file, $referer, this_post_data]
    this_command   = "if [ -f #{this_out_file} ] ; then echo 'Skipping #{this_out_file}' ; else #{this_command} ; fi"
    puts this_command # "%s <= %s" % [ this_out_file, this_post_data ]
    
    # check off the edges we just traversed
    pairs = journey.most.zip(journey.rest)
    pairs.each{ |p| trip_left.delete(p.sort) }
  end
  # warn if we missed some
  if (trip_left.length > 0) then puts "Never visited %s (%s)\n" % [ trip_left.keys.sort.to_json, trip_left.keys.sort.map{|c1,c2| "%s =} %s" % [cities[c1], cities[c2]]}.to_json ] end
end


#
# pulls the list of cities from the website's list
def get_cities_list(cities_file)
  # note -- you have to correct the line reading 'TYC HOUSTON DO' to say 'TYC HOUSTON DO      TX'
  # There's also an issue with HUNTSVILLE TX and HUNTSVILLE AR
  # slurp
  cities = File.open(cities_file) do |f| f.readlines().map(&:chomp) end
  # make [city, state] assoc's
  cities = cities.map{|city| city.match(%r!^(.*?)\s+(..)$!).captures().map{|s| s.gsub(' ','+')} }
  # stuff in 'city++" to force exact matching; but chop at 22 characters
  cities = cities.map{|city,st| [ (city+'++')[0..21], st ]  }
end

#
#
def run_and_parse_wget()
  # result = `#{this_command}`.split("\n")
  # result = File.open(this_out_file) do |f| f.readlines().map(&:chomp) end
  # result = result.grep(%r!<TD!i)
end

cities        = get_cities_list($cities_file) # [0..500]
# puts cities.to_json
# get_journeys(cities, $segs_n).each{|city| puts city.to_json}
journeys_dump_wgets(cities, $segs_n)

