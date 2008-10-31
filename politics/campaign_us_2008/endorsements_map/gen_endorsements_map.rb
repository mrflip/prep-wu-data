#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'yaml'; require 'json'
require 'imw/utils/extensions/core'
require 'active_support'
require 'action_view/helpers/number_helper'; include ActionView::Helpers::NumberHelper
#
require 'lib/endorsement'
require 'lib/geolocation'
require 'lib/metropolitan_areas'
require 'lib/utils'
#


#
# offset abutting cities
#
def fixed_lat_lng_overlap e
  case e.city
  when 'Honolulu'  then lng, lat = Geolocation.ll_from_xy(279, 564-466);  return [round2(lat), round2(lng)]
  when 'Anchorage' then lng, lat = Geolocation.ll_from_xy(128, 564-469);  return [round2(lat), round2(lng)]
  when ''          then lng, lat = Geolocation.ll_from_xy(629, 0);        return [round2(lat), round2(lng)]
  end
  lat, lng = e.values_of(:lat, :lng)
  return unless lat && lng
  lngshifts = {
    'Chicago Sun-Times' =>  0.4, 'Chicago Tribune'    => -0.2, 'Southwest News-Herald' =>  0.1,
    'The Seattle Times' => -0.2, 'The Capital Times'  => -0.2,
    'New York Post'     =>  0.4, 'The Daily News'     => -0.2, 'The New York Times' => 0.8,
    'The Wall Street Journal' => 1,
    'el Diario'         =>  0.1, 'Yamhill Valley News-Register' =>  0.1,
    'La Opinion'        =>  0.3, 'Los Angeles Daily News'     =>  -0.4,
    'Las Vegas Sun'     => -0.2, 'Las Vegas Review-Journal' => 0.2,
    'Chattanooga Times' => -0.2, 'The Chattanooga Free Press' => 0.2,
  }
  latshifts = {
    'The New York Times' => -0.4,
    'The Wall Street Journal' => -0.4,
  }
  if (lng_shift = lngshifts[e.paper]) then lng += lng_shift end
  if (lat_shift = latshifts[e.paper]) then lat += lat_shift end
  [round2(lat), round2(lng)]
end


#
# XML-able hash for amcharts point
#
def point_for_graph endorsement, content=nil, movement=nil
  hsh                = { }
  movement         ||= endorsement.mv0408
  hsh['content']     = content || popup_text(endorsement)
  hsh['y'], hsh['x'] = fixed_lat_lng_overlap(endorsement)
  hsh['value']       = Math.sqrt(endorsement.circ_with_split)
  # Bullet Appearance
  hsh['bullet_color'] = {
    -3 => 'ff1111', -2 => 'cc7777', -1 => 'cc7777', nil => '888888',
     3 => '1111ff',  2 => '7777cc',  1 => '7777cc',             }[movement]
  hsh['bullet_alpha'] = {
    -3 => 60, -2 => 60, -1 => 60, nil => 15,
     3 => 60,  2 => 60,  1  => 60,                              }[movement]
  hsh['bullet'] = {
    -3 => 'round_outline', -2 => 'bubble', -1 => 'bubble', nil => 'round',
     3 => 'round_outline',  2 => 'bubble',  1 => 'bubble',      }[movement]
  hsh.each{|k,v| if !v then puts "Unset value for #{k} in #{hsh['content']}"; hsh[k] = '' end }
  hsh
end
#
# Readable text for the popup balloon
#
def popup_text e
  "%s <br />%s<br />%s<br />circulation %s%s" % (
    [e.paper, e.city_st, e.endorsement_hist_str(true), e.circ_as_text, e.rank_as_text])
end
#
# XML-able hash for whole amcharts graph
#
def hash_for_graph endorsements, endorsement_bins
  endorsements = endorsements.values.sort_by{|e| -e.circ_with_split } # must be by circ so bubbles don't get buried
  hsh = { 'chart' => { 'graphs' => { 'graph' => [
          # points
          { 'gid' => 0, 'point' =>
            endorsements.find_all(&:interesting?).map{|e| point_for_graph(e)} +  #
            # fake_points +
            [ { 'x' => -71.0, 'y' => Geolocation.ll_from_xy(40, 100 - 7)[1], 'value' => Math.sqrt(2_100_000), 'bullet_alpha' => 0 }, ] # sets the max size
          },
          { 'gid' => 1, 'title' => 'Endorsement Legend', 'point' => summary_points(endorsements, endorsement_bins)},
          { 'gid' => 2, 'title' => 'Circulation Legend', 'point' => [
              { 'x' =>  -50.0, 'y' => Geolocation.ll_from_xy(40, 100 - 7)[1], 'value' => Math.sqrt(2_100_000), 'bullet_alpha' => 0 },
              # { 'x' => -118.4, 'y' => 33.93,                      'value' => Math.sqrt(  773_884), 'content' => 'Circulation 250,000', 'bullet' => 'square' },
              { 'x' => Geolocation.ll_from_xy(1000-80,  0)[0], 'y' => Geolocation.ll_from_xy(0, 198 - 7)[1], 'value' => Math.sqrt(  500_000), 'content' => '500k' },
              { 'x' => Geolocation.ll_from_xy(1000-80,  0)[0], 'y' => Geolocation.ll_from_xy(0, 175 - 7)[1], 'value' => Math.sqrt(   50_000), 'content' => '50k' },
          ]}
        ]}}}
  XmlSimple.xml_out hsh, 'KeepRoot' => true
end
#
# Generate AMCharts graph
#
def dump_hash_for_graph endorsements, graph_xml_filename, endorsement_bins
  puts "Writing to graph file #{graph_xml_filename}"
  File.open(graph_xml_filename, 'w') do |graph_xml_out|
    graph_xml_out << hash_for_graph(endorsements, endorsement_bins)
  end
end

#
#
#
def summary_points endorsements, endorsement_bins
  legend_points = []
  yval_for_mv = { 'O' => 122, 3=>100, 1 => 80, 'M' => 57, -1 => 35, -3 => 15 };
  xval = 150
  prez_for_mv = { 3=>'Obama', 1 => 'Obama',      -1 => 'McCain',    -3 => 'McCain' };
  prev_for_mv = { 3=>'Bush',  1 => 'Kerry or none', -1 => 'Bush or none', -3 => 'Kerry' };
  #
  tot_p = { }; tot_c = { }; [-3, -1, 1, 3].each do |mv|
    tot_p[mv] = endorsement_bins[mv][:papers].length; tot_c[mv] = endorsement_bins[mv][:total_circ]
  end
  [3, 1, -1, -3].each do |mv|
    lng, lat = Geolocation.ll_from_xy(1000-xval, yval_for_mv[mv])
    legend_popup  = "Now endorsing %s,<br/>endorsed %s in 2004<br/>%s papers, ~%s circ."% [prez_for_mv[mv], prev_for_mv[mv], tot_p[mv], as_millions(tot_c[mv]), ]
    e = Endorsement.new('','','','','',0,7500,0,0,lat,lng)
    legend_points << point_for_graph(e, legend_popup, mv ).merge({ 'bullet_alpha' => 70 })
    label_text    = "%s in '04"% [ prev_for_mv[mv] ]
    puts "<label> <x>!#{xval-19}</x> <y>!#{yval_for_mv[mv]+5}</y> <text>#{label_text}</text> <align>left</align> <text_size>13</text_size> <text_color>444444</text_color> </label>"
  end
  [ ['O', "%s (%s/~%s tot)"% ['Obama',  tot_p[ 3] + tot_p[ 1], as_millions(tot_c[ 3]+tot_c[ 1]) ]],
    ['M', "%s (%s/~%s tot)"% ['McCain', tot_p[-3] + tot_p[-1], as_millions(tot_c[-3]+tot_c[-1]) ]],
  ].each do |mv, label_text|
    puts "<label> <x>!#{xval+5}</x> <y>!#{yval_for_mv[mv]}</y> <text>#{label_text}</text> <align>left</align> <text_size>13</text_size> <text_color>444444</text_color> </label>"
  end
  legend_points
end

dump_hash_for_graph Endorsement.all, 'web/chart/endorsements-map.xml', Endorsement.endorsement_bins
