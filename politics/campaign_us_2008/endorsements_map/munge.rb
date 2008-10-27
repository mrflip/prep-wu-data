#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'yaml'
require 'xmlsimple'
require 'imw/utils/extensions/core'
require 'active_support'
require 'action_view/helpers/number_helper'; include ActionView::Helpers::NumberHelper
#
require 'state_abbreviations'
require 'newspaper_mapping'
require 'cities_mapping'
require 'map_projection'
require 'endorsement'
require 'metropolitan_areas'
require 'dump'

# Presidential Endorsements by Major Newspapers in the 2008 General Election
# Editor & Publisher
# http://www.editorandpublisher.com/eandp/news/article_display.jsp?vnu_content_id=1003875230
# election 2008 election2008 president general newspaper endorsement politics
# Source data by Dexter Hill and Greg Mitchell Editor & Publisher

# to spot check count
# cat rawd/endorsements-raw-20081020.txt | egrep  '^\(?.[a-z]' | wc -l

#
# Extract the endorsements
#
PROCESS_DATE = '20081024'
raw_filename       = "rawd/endorsements-raw-#{PROCESS_DATE}.txt"
tsv_out_filename   = "fixd/endorsements-cooked.tsv"
graph_xml_filename = "fixd/endorsements-graph.xml"
endorsements = parse_ep_endorsements(raw_filename)

#
# add in those top-100 newspapers not yet listed
#
NEWSPAPER_CIRCS.each do |paper, info|
  next if endorsements.include?(paper)
  rank, circ, daily, sun, lat, lng, st, city, valid = info
  lat, lng = get_city_coords(city, st) if ( st && !lat )
  lat ||= 0; lng ||= 0
  # :prez, :prev, :rank, :circ, :daily, :sun, :lat, :lng, :st, :city, :paper)
  endorsements[paper] = Endorsement.new('', '', rank, circ, daily, sun, lat, lng, st, city, paper)
end
#
# Post-process the full list
#
endorsements.sort_by{|p,e| -e.circ}.each_with_index do |pe,i|
  paper, endorsement = pe
  # Assign an overall rank
  # (note that this *isn't* the 'national rank' -- papers out of the top 100 could be missing, and split endorsements mess this up)
  endorsement.all_rank = i+1
  # Dig up the metro, if any
  endorsement.metro    = CityMetro.get(endorsement.st, endorsement.city)
end

#
# Run the graph generation
#
dump_hash_for_graph endorsements, graph_xml_filename, endorsement_bins

#
# Dump as tsv too
#
# puts "Writing to intermediate file #{tsv_out_filename}"
# File.open(tsv_out_filename, 'w') do |tsv_out|
#   tsv_out << Endorsement.members.map{|s| s.capitalize}.join("\t") + "\n"
#   endorsements.sort_by{|p,e| -e.circ }.each do |paper, endorsement|
#     tsv_out << endorsement.to_a.join("\t")+"\n"
#   end
# end
dump_yaml endorsements
dump_csv  endorsements
dump_csv  endorsements, :separator => "\t"
