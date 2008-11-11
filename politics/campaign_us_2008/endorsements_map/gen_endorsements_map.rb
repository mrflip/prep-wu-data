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
NEWSPAPER_CITIES  = YAML.load(File.open("data/newspaper_cities.yaml"))

LNGSHIFTS = {
  'Chicago Sun Times' =>  0.4, 'Chicago Tribune'    => -0.2,
  'Seattle Times'     => -0.2, 'Capital Times'  => -0.2,
  'New York Post'     =>  0.4, 'Daily News (New York City)'     => -0.2, 'New York Times' => 0.8,
  'Wall Street Journal' => 1,
  'el Diario'         =>  0.1,
  'La Opinion'        =>  0.3, 'Daily News (Los Angeles)'     =>  -0.4,
  'Orange County Register'  =>  0.5,
  'Las Vegas Sun'     => -0.2, 'Las Vegas Review Journal' => 0.2,
  'Chattanooga Times' => -0.2, 'Chattanooga Free Press' => 0.2,
}
LATSHIFTS = {
  'New York Times' => -0.4,
  'Wall Street Journal' => -0.4,
  'Orange County Register'  =>  0.5,
}
LNGSHIFTS.each{|k,v| warn "Oops paper #{k} not in list" unless NEWSPAPER_CITIES[k] }
LATSHIFTS.each{|k,v| warn "Oops paper #{k} not in list" unless NEWSPAPER_CITIES[k] }
def fixed_lat_lng_overlap e
  case e.city
  when 'Honolulu'  then lng, lat = Geolocation.ll_from_xy(279, 564-466);  return [round2(lat), round2(lng)]
  when 'Anchorage' then lng, lat = Geolocation.ll_from_xy(128, 564-469);  return [round2(lat), round2(lng)]
  when 'Juneau'    then lng, lat = Geolocation.ll_from_xy(185, 564-482);  return [round2(lat), round2(lng)]
  when ''          then lng, lat = Geolocation.ll_from_xy(999629, 0);        return [round2(lat), round2(lng)]
  end
  lat, lng = e.values_of(:lat, :lng)
  return unless lat && lng
  if (lng_shift = LNGSHIFTS[e.paper]) then lng += lng_shift end
  if (lat_shift = LATSHIFTS[e.paper]) then lat += lat_shift end
  [round2(lat), round2(lng)]
end


def bullet_alpha(movement)
  {
    -3 => 60, -2 => 60, -1 => 60,  nil  => 15,  'dn'  => 15,
     3 => 60,  2 => 60,  1  => 60, 'ab' => 33,                   }[movement]
end
def bullet_color(movement)
  {
    -3 => 'ff1133', -2 => 'cc7777', -1 => 'cc7777', nil => '888888', 'dn' => '888888',
     3 => '3311ff',  2 => '7777cc',  1 => '7777cc', 'ab' => 'dddd99'     }[movement]
end
def bullet(movement)
  {
    -3 => 'round_outline', -2 => 'bubble', -1 => 'bubble', nil  => 'round', 'dn' => 'round',
     3 => 'round_outline',  2 => 'bubble',  1 => 'bubble', 'ab' => 'round'     }[movement]
end
# Bullet Appearance
def bullet_props(mv)
  Hash.zip(['bullet_alpha', 'bullet_color', 'bullet'], [ bullet_alpha(mv), bullet_color(mv), bullet(mv) ])
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
  hsh.merge!(bullet_props(movement))
  hsh.each{|k,v| if !v then puts "Unset value for #{k} in #{hsh.inspect} with #{movement.inspect}"; hsh[k] = '' end }
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
            endorsements.find_all(&:interesting?).reject{|e| e.circ < 0 }.map{|e| point_for_graph(e)} +  #
            # fake_points +
            [ { 'x' => -71.0, 'y' => Geolocation.ll_from_xy(40, 100 - 7)[1], 'value' => Math.sqrt(2_100_000), 'bullet_alpha' => 0 }, ] # sets the max size
          },
          { 'gid' => 1, 'title' => 'Endorsement Legend', 'point' => summary_points(endorsements, endorsement_bins)},
          { 'gid' => 2, 'title' => 'Circulation Legend', 'point' => [
              { 'x' =>  -50.0, 'y' => Geolocation.ll_from_xy(40, 100 - 7)[1], 'value' => Math.sqrt(2_100_000), 'bullet_alpha' => 0 },
              # { 'x' => -118.4, 'y' => 33.93,                      'value' => Math.sqrt(  773_884), 'content' => 'Circulation 250,000', 'bullet' => 'square' },
              { 'x' => Geolocation.ll_from_xy(1000-80,  0)[0], 'y' => Geolocation.ll_from_xy(0, 228 - 7)[1], 'value' => Math.sqrt(  500_000), 'content' => '500k' },
              { 'x' => Geolocation.ll_from_xy(1000-80,  0)[0], 'y' => Geolocation.ll_from_xy(0, 205 - 7)[1], 'value' => Math.sqrt(   50_000), 'content' => '50k' },
          ]}
        ]}}}
  XmlSimple.xml_out hsh, 'KeepRoot' => true
end
#
# Generate AMCharts graph
#
def dump_hash_for_graph endorsements, graph_xml_filename, endorsement_bins
  puts Time.now.to_s+" Writing to graph file #{graph_xml_filename}"
  File.open(graph_xml_filename, 'w') do |graph_xml_out|
    graph_xml_out << hash_for_graph(endorsements, endorsement_bins)
  end
end

#
#
#
def summary_points endorsements, endorsement_bins
  legend_points = []
  yval_for_mv = { 'O' => 145, 3=>123, 1 => 103, 'M' =>  80, -1 =>  58, -3 =>  38, 'ab' =>  15, nil =>  15 };
  xval_for_mv = { 'O' => 160, 3=>160, 1 => 160, 'M' => 160, -1 => 160, -3 => 160, 'ab' => 109, nil =>  35 };
  prez_for_mv = { 3=>'Obama', 1 => 'Obama',         -1 => 'McCain',       -3 => 'McCain' };
  prev_for_mv = { 3=>'Bush',  1 => 'Kerry or none', -1 => 'Bush or none', -3 => 'Kerry' };
  #
  tot_p = { }; tot_c = { }; [-3, -1, 1, 3, 'ab', nil].each do |mv|
    tot_p[mv] = endorsement_bins[mv][:papers].length; tot_c[mv] = endorsement_bins[mv][:total_circ]
  end
  [3, 1, -1, -3, 'ab', nil].each do |mv|
    lng, lat = Geolocation.ll_from_xy(1000-xval_for_mv[mv], yval_for_mv[mv])
    case mv
    when 'ab' then alpha = 50; legend_popup = 'Will not be endorsing a candidate this year.'
    when nil  then alpha = 30; legend_popup = 'Has not yet endorsed'
    else           alpha = 70; legend_popup = "Now endorsing %s,<br/>endorsed %s in 2004"% [prez_for_mv[mv], prev_for_mv[mv] ]
    end
    legend_popup += "<br/>%s papers, ~%s circ."%[tot_p[mv], as_millions(tot_c[mv]), ]
    hsh = bullet_props(mv)
    hsh.merge! 'content' => legend_popup, 'x' => lng, 'y' => lat,
      'value' => Math.sqrt(7500), 'bullet_alpha' => alpha
    legend_points << hsh
  end
  legend_points
end

dump_hash_for_graph Endorsement.all, 'web/chart/endorsements-map.xml', Endorsement.endorsement_bins
