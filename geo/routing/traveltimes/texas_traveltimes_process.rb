#!/usr/bin/env ruby
$:.unshift ENV['HOME']+'/ics/code/lib/ruby/lib' # find infinite monkeywrench lib
require 'imw.rb'
require 'yaml'
require 'fastercsv'

task :default => :mileagegrid
$result_files = 
  {
   :city_ids      => 'rawd/dump/city_ids.csv',
   :city_mileages => 'rawd/dump/city_mileages.csv',
   :all_mileages  => 'rawd/dump/all_mileages.csv',
}

# extract the 
(0..204).each do |chunk|
  chunk_file = "rawd/dump/texas/texas_chunk_%03d.txt" % [chunk]
  chunk_dir  = "rawd/dump/texas/%03d"                 % [chunk]
  task :chunk => chunk_file
  file chunk_file => chunk_dir do
    # perl -ne way faster than grep.
    sh %{ perl -ne 'm!^\\s{12,}<td!i && print;' #{chunk_dir}/* > #{chunk_file} }
  end
end


desc "Label each city with a unique numeric ID, and dump the city pair mileages"
task :traveltimes => [:chunk] do
  city_ids = {} # uniq id for each [city,st]
  mileages = {} # mileage for each id pair
  Dir['rawd/dump/texas/texas_chunk_???.txt'].each do |chunk_filename|
    puts "grabbing mileages from %s:" % [chunk_filename]
    File.open(chunk_filename) do |chunk_file|
      while !chunk_file.eof? do
        city_a  = %r!<TD>(.*), ([A-Z][A-Z])\s*</TD>!o.match(chunk_file.readline()).captures
        city_b  = %r!<TD>(.*), ([A-Z][A-Z])\s*</TD>!o.match(chunk_file.readline()).captures
        mileage = %r!<TD ALIGN=RIGHT>(.*)</TD>!o.match(chunk_file.readline())[1].to_f
        # puts "%-50s|%2s|%-50s|%2s|%-8.1f" % [city_a, city_b, mileage].flatten
        
        city_a_id = identify(city_ids, city_a)
        city_b_id = identify(city_ids, city_b)
        mileages[ [city_a_id, city_b_id] ] = mileage
      end
    end # 
  end # chunk_file
  
  dump_ids(     $result_files[:city_ids],      city_ids)
  dump_all_mileages( $result_files[:city_mileages], city_ids, mileages)
  dump_city_mileages($result_files[:city_mileages], city_ids, mileages)
end # task
task $result_files[:city_ids]      => :traveltimes
file $result_files[:city_mileages] => :traveltimes

desc "Create the grid of mileages to each other city"
file $result_files[:all_mileages] => [$result_files[:city_ids], $result_files[:city_mileages]] do
  city_ids, city_mileages = load_ids($result_files[:city_ids], $result_files[:city_mileages])
  dump_all_mileages($result_files[:all_mileages], city_ids, mileages)
end
task :all_mileages => $result_files[:all_mileages]

#
# load city IDs and city pair mileages
def load_ids(city_ids_filename, city_mileages_filename)
  city_ids      = FasterCSV.read(city_ids_filename)
  city_mileages = FasterCSV.read(city_mileages_filename)
  [city_ids, city_mileages]
end

#
# ids for each city
def dump_ids(dump_filename, city_ids)
  FasterCSV.open(dump_filename, 'wb') do |dump_file|
    city_ids.each do |city_st, id| 
      dump_file << [city_st, id].flatten 
    end
  end  
end

#
# grid of mileages, for each city pair
def dump_city_mileages(dump_filename, city_ids, mileages)
  FasterCSV.open(dump_filename, 'wb') do |dump_file|
    (1..city_ids.length).each do   |city_a_id|
      (1..city_ids.length).each do |city_b_id|
        pair = [city_a_id, city_b_id]
        dump_file << [city_a_id, city_b_id, mileages[pair]] if mileages.include?(pair)
      end
    end  
  end
end

#
# grid of mileages to each other city from each city
def dump_all_mileages(dump_filename, city_ids, mileages)
  FasterCSV.open(dump_filename, 'wb') do |dump_file|
    # for each city,
    (1..city_ids.length).each do   |city_a_id|
      # print the array of mileages (if any) to each other city
      row = (0..city_ids.length).map do |city_b_id|
        pair = [city_a_id, city_b_id]
        mileages.include?(pair) ? mileages[pair] : -1
      end
      dump_file << [city_a_id] + row
    end  
  end
end

#
# Given an element and a hash of identified elements, 
# assign a unique id to the element if not previously identified, and
# return the unique id of the element
#
# Note that IDs start at 1, for compatibility with most DB programs
def identify(table, el)
  table[el] = table.length+1 if !table.include?(el)
  table[el]
end


# rawd/dump/texas/080/texas-801_289_802_288_803_289_804_288_805.html:                             <TD>LAMPASAS, TX</TD>
# rawd/dump/texas/080/texas-801_289_802_288_803_289_804_288_805.html:                             <TD>CLOUDCROFT, NM  </TD>
# rawd/dump/texas/080/texas-801_289_802_288_803_289_804_288_805.html:                             <TD ALIGN=RIGHT>526.4</TD>
# rawd/dump/texas/080/texas-801_289_802_288_803_289_804_288_805.html:                             <TD>CLOUDCROFT, NM</TD>
# rawd/dump/texas/080/texas-801_289_802_288_803_289_804_288_805.html:                             <TD>LANCASTER, TX  </TD>
# rawd/dump/texas/080/texas-801_289_802_288_803_289_804_288_805.html:                             <TD ALIGN=RIGHT>561.7</TD>
