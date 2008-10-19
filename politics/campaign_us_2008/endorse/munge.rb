#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'yaml'
require 'xmlsimple'
require 'imw/utils/extensions/core'
#
require 'state_abbreviations'
require 'newspaper_mapping'
require 'cities_mapping'
require 'map_projection'

Endorsement = Struct.new(:prez, :prev, :movement, :circ, :lat, :lng, :country, :st, :city, :fixme, :paper, :state)

def get_endorsements(raw_filename)
  endorsements = []
  File.open(raw_filename) do |f|
    3.times do f.readline end
    prez  = 'BO'
    city  = ''
    state = ''
    country = 'us'
    f.each do |l|
      l.chomp!
      next if l =~ /^\s*$/
      case
      when (l.upcase == l)
        state = l.downcase
      when (l == 'JOHN McCAIN')
        prez = 'JM'
        2.times{f.readline}
      else
        m = /^(.*?)(?: \((B|K|N\/A|)\))?: ([0-9,]+)?/.match(l)
        if m
          paper, prev, circ = m.captures.map{|e| (e||'').strip}
          circ = circ.gsub(/[^0-9]/,'').to_i
          st = STATE_ABBREVIATIONS[state.upcase]
          city, lat, lng, paper, fixme = fix_city_and_paper(paper, st)
          movement = get_movement(prev, prez)
          lat, lng = get_city_coords(city, st)
          # offset abutting
          case
          when ['The Seattle Times', 'The Capital Times', 'La Opinion'].include?(paper)                         then lng -= 0.2
          when ['el Diario La Prensa', 'Southwest News-Herald', 'Yamhill Valley News-Register'].include?(paper) then lng += 0.1
          when ['Chicago Tribune',   'The Daily News'].include?(paper) then  lng -= 0.2
          when ['Chicago Sun-Times', 'New York Post' ].include?(paper) then  lng += 0.6
          when (city == 'Honolulu') then lng, lat = ll_from_xy(380,758-626)
          end
          endorsements << Endorsement.new(prez, prev, movement, circ, lat, lng, country, st, city, fixme, paper)
        else
          puts "Bad Line '#{l}'"
        end
      end
    end
  end
  endorsements
end

MOVEMENT_FROM = { 'B'  => -1, ''   => 0, 'N/A' => 0, 'K' => 1, }
MOVEMENT_TO   = { 'JM' => -2, 'BO' => 2, }
def get_movement prev, prez
  MOVEMENT_TO[prez] - MOVEMENT_FROM[prev||'']
end

def fix_coord coord
  if coord =~ / ([NSEW])/
    sgn = { "N" => 1, "E" => 1, "W" => -1, "S" => -1}[$1]
    m = /([\d\.]+)°(?: ([\d\.]+)\'(?: ([\d\.]+)\")?)? ([NSEW])/.match(coord)
    if m
      deg, min, sec, _ = m.captures
      coord = sgn * (deg.to_f + (min||0).to_f/60 + (sec||0).to_f/3600)
    else
      coord = sgn * coord[0..-3].to_f
    end
  end
  coord
end
def fix_city_and_paper(paper, st)
  fixme, lat, lng = ['', 0, 0]
  if paper =~ /^(.*) \((.*)\)(.*)/
    paper, city = [$1+($3||''), $2]
  end
  case
  when NEWSPAPER_MAPPING.include?(paper)
    city, raw_lat, raw_lng, conv = NEWSPAPER_MAPPING[paper]
    lat = fix_coord raw_lat
    lng = fix_coord raw_lng
    if get_city_coords(city, st)[0] then lat, lng = get_city_coords(city, st)  end
    unless conv
     puts '  %-40s => [%-25s %-12s %-12s true,], # %s' % ["\"#{paper}\"", "\"#{city}\",", "#{'%10.5f'%lat},", "#{'%10.5f'%lng},", st]
    end
  else
    city  = paper.gsub(/^The /, '').gsub(/([^ ]*) ([^ ]*).*?/, '\1 \2')
    fixme = city
    lat, lng = get_city_coords(city, st)
    puts '  %-40s => [%-25s %-12s %-12s],' % ["\"#{paper}\"", "\"#{city}\",", "#{'%10.5f'%(lat||0)},", "#{'%10.5f'%(lng||0)},"]
  end
  [city, lat, lng, paper, fixme]
end

def popup_text endorsement
  peeps = [
    { 'B'  => 'Bush',   ''   => 'None', 'N/A' => 'None', 'K' => 'Kerry', }[endorsement[:prev]],
    { 'JM' => 'McCain', 'BO' => 'Obama', }[endorsement[:prez]]
  ]
  circ = [ endorsement.circ == 0 ? 'unknown' : endorsement.circ ]
  "%s <br />%s, %s<br />circulation %s<br />2004: %s 2008: %s" % (endorsement.values_of(:paper, :city, :st)+circ+peeps)
end



def point_for_graph endorsement, content=nil
  hsh = { }
  # hsh['content'] = "#{endorsement[:city]} - #{endorsement[:lng]} - #{hsh['x']} | #{endorsement[:lat]} - #{hsh['y']}"
  hsh['content'] = content || popup_text(endorsement)
  hsh['x'], hsh['y'] = [ endorsement[:lng], endorsement[:lat] ]
  hsh['value'] = Math.sqrt(endorsement[:circ])
  hsh['bullet_color'] = {
    -3 => 'ff1111', -2 => 'cc7777', -1 => 'cc7777', 0 => '999999',
     3 => '1111ff',  2 => '7777cc',  1 => '7777cc',
  }[endorsement[:movement]]
  hsh['bullet_alpha'] = {
    -3 => 60, -2 => 60, -1 => 60, 0 => 60,
     3 => 60,  2 => 60,  1  => 60,
  }[endorsement[:movement]]
  hsh['bullet'] = {
    -3 => 'round_outline', -2 => 'bubble', -1 => 'bubble', 0 => 'bubble',
     3 => 'round_outline',  2 => 'bubble',  1 => 'bubble',
  }[endorsement[:movement]]
  hsh.each{|k,v| hsh[k] ||= '' }
  hsh
end
def hash_for_graph endorsements
  endorsements = endorsements.sort_by{|e| -e[:circ] } # must be by circ so bubbles don't get buried
  hsh = { 'chart' => { 'graphs' => { 'graph' => [
          { 'gid' => 0,
            'point' => endorsements.map{|e| point_for_graph(e)} +
            # fake_points +
            [
              { 'x' => -71.0, 'y' => ll_from_xy(40, 100 - 7)[1], 'value' => Math.sqrt(2_100_000), 'bullet_alpha' => 0 },
            ]
          },
          { 'gid' => 1, 'title' => 'Obama',
            'point' => [
              point_for_graph({ :lng => -77.75, :lat => ll_from_xy(33,115 - 5)[1], :movement =>  3, :circ =>  7500 }, 'Endorsed Obama (Bush in 04)' ),
              point_for_graph({ :lng => -77.75, :lat => ll_from_xy(33, 91 - 5)[1], :movement =>  2, :circ =>  7500 }, 'Endorsed Obama (Kerry or None in 04)' ),
              point_for_graph({ :lng => -77.75, :lat => ll_from_xy(33, 68 - 5)[1], :movement => -2, :circ =>  7500 }, 'Endorsed McCain (Bush or None in 04)' ),
              point_for_graph({ :lng => -77.75, :lat => ll_from_xy(33, 45 - 5)[1], :movement => -3, :circ =>  7500 }, 'Endorsed McCain (Kerry in 04)'       ),
          ]},
          { 'gid' => 2, 'title' => 'Obama',
            'point' => [
              { 'x' =>  -71.0, 'y' => ll_from_xy(40, 100 - 7)[1], 'value' => Math.sqrt(2_100_000), 'bullet_alpha' => 0 },
              # { 'x' => -118.4, 'y' => 33.93,                      'value' => Math.sqrt(  773_884), 'content' => 'Circulation 250,000', 'bullet' => 'square' },
              { 'x' => ll_from_xy(1345-150,  94 - 7)[0], 'y' => ll_from_xy(40, 212 - 7)[1], 'value' => Math.sqrt(  500_000), 'content' => '500k' },
              { 'x' => ll_from_xy(1345-150,  94 - 7)[0], 'y' => ll_from_xy(40, 175 - 7)[1], 'value' => Math.sqrt(   25_000), 'content' => '25k' },
          ]}
        ]}}}
  XmlSimple.xml_out hsh, 'KeepRoot' => true
end
def dump_hash_for_graph endorsements, graph_xml_filename
  puts "Writing to graph file #{graph_xml_filename}"
  File.open(graph_xml_filename, 'w') do |graph_xml_out|
    graph_xml_out << hash_for_graph(endorsements)
  end
end


PROCESS_DATE = '20081019'
raw_filename       = "rawd/endorsements-raw-#{PROCESS_DATE}.txt"
tsv_out_filename   = "fixd/endorsements-cooked-#{PROCESS_DATE}.tsv"
graph_xml_filename = "fixd/endorsements-graph-#{PROCESS_DATE}.xml"
endorsements = get_endorsements(raw_filename)
puts "Writing to intermediate file #{tsv_out_filename}"
File.open(tsv_out_filename, 'w') do |tsv_out|
  tsv_out << Endorsement.members.map{|s| s.capitalize}.join("\t") + "\n"
  endorsements.each do |endorsement|
    tsv_out << endorsement.to_a.join("\t")+"\n"
  end
end
dump_hash_for_graph endorsements.reject{|e| ['AK' ].include?(e.st) }, graph_xml_filename

def comma_float(f)
  s = f ? ('%10.5f' % f) : ''
  "#{s},"
end

# Presidential Endorsements by Major Newspapers in the 2008 General Election
# Editor & Publisher
# http://www.editorandpublisher.com/eandp/news/article_display.jsp?vnu_content_id=1003875230
# election 2008 election2008 president general newspaper endorsement politics
# Source data by Dexter Hill and Greg Mitchell Editor & Publisher

# endorsements.sort_by(&:city).each do |e| puts('#  [%-21s %-3s "",  ], #%s%-20s%s' %
#     ["\"#{e.city}\",", "\"#{e.st}\",",
#       %Q{\nwget -O- \"http://www.census.gov/cgi-bin/gazetteer?},
#       '%s,+%s"' % [e.city.gsub(/\s/,"+"), e.st],
#       %q{-nv 2>/dev/null | egrep -i '(<li><strong|Location)'},
#     ]) if (!get_city_coords(e.city, e.st)[1]) end
