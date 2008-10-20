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

# Presidential Endorsements by Major Newspapers in the 2008 General Election
# Editor & Publisher
# http://www.editorandpublisher.com/eandp/news/article_display.jsp?vnu_content_id=1003875230
# election 2008 election2008 president general newspaper endorsement politics
# Source data by Dexter Hill and Greg Mitchell Editor & Publisher

# to spot check count
# cat rawd/endorsements-raw-20081019.txt | egrep  '^\(?.[a-z]' | wc -l


MOVEMENT_FROM = { 'B'  => -1, ''   => 0, 'N/A' => 0, 'K' => 1, }
MOVEMENT_TO   = { 'McCain' => -2, 'Obama' => 2, }
PREZ04        = { 'B'  => 'Bush', ''   => '(none)', 'N/A' => '(none)', 'K' => 'Kerry', }
class Endorsement < Struct.new(
  :prez, :prev, :rank, :circ, :daily, :sun, :lat, :lng, :st, :city, :paper,
  :movement, :prez04 # don't set these -- will be set from other attrs
  )
  def initialize(*args)
    super *args
    # fix attributes
    fix_movement
    fix_lat_lng_overlap
    self.prez04 = PREZ04[prev]
  end
  #
  # score the endorsement: 1 point for d=>d, 2 for none => d, 3 for r => d
  # (and similarly for * => r)
  #
  def fix_movement
    if prez == ''
      self.movement = nil
    else
      self.movement = MOVEMENT_TO[prez] - MOVEMENT_FROM[prev]
    end
  end
  #
  # offset abutting cities
  #
  def fix_lat_lng_overlap
    return unless lat && lng
    case
    when ['The Seattle Times', 'The Capital Times', 'La Opinion'].include?(paper)
      self.lng -= 0.2
    when ['el Diario', 'Southwest News-Herald', 'Yamhill Valley News-Register'].include?(paper)
      self.lng += 0.1
    when ['Chicago Tribune',   'The Daily News'].include?(paper)
      self.lng -= 0.2
    when ['Chicago Sun-Times', 'New York Post' ].include?(paper)
      self.lng += 0.6
    when (city  == 'Honolulu')
      self.lng, self.lat = ll_from_xy(380,  758-626)
    end
    self.lat = (lat*100).round()/100.0
    self.lng = (lng*100).round()/100.0
  end
end

def get_endorsements(raw_filename)
  endorsements = {}
  File.open(raw_filename) do |f|
    3.times do f.readline end
    prez  = 'Obama'
    city  = ''
    state = ''
    f.each do |l|
      l.chomp!
      l.gsub!(/Foster.*s Daily/, 'Foster\'s Daily')
      next if l =~ /^\s*$/
      case
      when (l.upcase == l)
        state = l.downcase
      when (l == 'JOHN McCAIN')
        prez = 'McCain'
        2.times{f.readline}
      else
        m = /^([^\:]*?)(?: \((B|K|N\/A|)\))?:? *([0-9,]+)?$/.match(l)
        if m
          paper, prev, circ = m.captures.map{|e| (e||'').strip};
          prev ||= ''
          circ   = (circ||'').gsub(/[^0-9]/,'').to_i
          # parse out city, get location
          rank, circ, daily, sun, lat, lng, st, city, paper = fix_city_and_paper(paper, state, circ)
          # ok, you're endorsed
          endorsements[paper] = Endorsement.new(prez, prev, rank, circ, daily, sun, lat, lng, st, city, paper)
        else
          puts "Bad Line '#{l}'"
        end
      end
    end
  end
  endorsements
end

def fix_city_and_paper(orig_paper, state, circ)
  # extract embedded city info
  if orig_paper =~ /^(.*) \((.*)\)(.*)/
    paper, city = [$1+($3||''), $2]
  else
    paper = orig_paper
  end
  if (orig_paper =~ /Lowell.*Sun/) || (orig_paper =~ /Stockton.*Record/)
    paper = orig_paper
  end
  # and un-abbreviate state
  st = STATE_ABBREVIATIONS[state.upcase]
  case
  when NEWSPAPER_CIRCS.include?(paper)
    rank, circ2, daily, sun, lat, lng, st, city, needsfix = NEWSPAPER_CIRCS[paper]
    if circ == 0 then circ = daily end
    if needsfix
      lat, lng = get_city_coords(city, st)
      find_missing_cities(city, st) if !lat
      lat ||= 0; lng ||= 0
      dump_for_newspaper_mapping(rank, circ, daily, sun, lat, lng, st, city, paper, true, 'fixed loc')
    elsif circ2 != circ
      dump_for_newspaper_mapping(rank, circ, daily, sun, lat, lng, st, city, paper, false, 'fixed circ')
    end
  else
    rank, daily, sun = [0,0,0]
    city  ||= orig_paper.gsub(/^The /, '').gsub(/([^ ]*) ([^ ]*).*?/, '\1 \2')
    lat, lng = get_city_coords(city, st)
    lat ||= 0; lng ||= 0
    dump_for_newspaper_mapping(rank, circ, daily, sun, lat, lng, st, city, paper, true, 'needs city fixed')
  end
  if ['USA Today'].include?(paper) then city = "[National]"; st = '' ; lng, lat = ll_from_xy(1050, 758-75) end
  [rank, circ, daily, sun, lat, lng, st, city, paper]
end
def dump_for_newspaper_mapping rank, circ, daily, sun, lat, lng, st, city, paper, needsfix, comment
    puts '  %-40s => [%3d, %9d, %9d, %9d, %-9s %-9s "%s", %-30s %s], # %s' % [
      "\"#{paper}\"", rank, circ, daily, sun,
      "#{'%8.3f'%(lat)},", "#{'%8.3f'%(lng)},",  st, "\"#{city}\",", needsfix, comment]
end
# Find missing cities
def find_missing_cities city, st
  puts('%s%-20s%s' %
    [ %Q{wget -O- \"http://www.census.gov/cgi-bin/gazetteer?},
      '%s,+%s" ' % [city.gsub(/\s/,"+"), st],
      %q{ -nv 2>/dev/null | egrep -i '(<li><strong|Location)'},
    ]) if (!get_city_coords(city, st)[1])
end

#
# XML-able hash for amcharts point
#
def point_for_graph endorsement, content=nil
  hsh = { }
  # hsh['content'] = "#{endorsement[:city]} - #{endorsement[:lng]} - #{hsh['x']} | #{endorsement[:lat]} - #{hsh['y']}"
  hsh['content'] = content || popup_text(endorsement)
  hsh['x'], hsh['y'] = [ endorsement[:lng], endorsement[:lat] ]
  hsh['value'] = Math.sqrt(endorsement[:circ])
  # Bullet Appearance
  hsh['bullet_color'] = {
    -3 => 'ff1111', -2 => 'cc7777', -1 => 'cc7777', 0 => '999999',
     3 => '1111ff',  2 => '7777cc',  1 => '7777cc',             }[endorsement[:movement]]
  hsh['bullet_alpha'] = {
    -3 => 60, -2 => 60, -1 => 60, 0 => 60,
     3 => 60,  2 => 60,  1  => 60,                              }[endorsement[:movement]]
  hsh['bullet'] = {
    -3 => 'round_outline', -2 => 'bubble', -1 => 'bubble', 0 => 'bubble',
     3 => 'round_outline',  2 => 'bubble',  1 => 'bubble',      }[endorsement[:movement]]
  hsh.each{|k,v| puts "Unset value for #{k} in #{hsh['content']}" unless v; }
  hsh
end
#
# Readable text for the popup balloon
#
def popup_text endorsement
  circ = [ endorsement.circ == 0 ? 'unknown' : endorsement.circ ]
  "%s <br />%s, %s<br />2004: %s 2008: %s<br />circulation %s" % (endorsement.values_of(:paper, :city, :st, :prez04, :prez)+circ)
end
#
# XML-able hash for whole amcharts graph
#
def hash_for_graph endorsements, endorsement_bins
  endorsements = endorsements.values.sort_by{|e| -e[:circ] } # must be by circ so bubbles don't get buried
  hsh = { 'chart' => { 'graphs' => { 'graph' => [
          # points
          { 'gid' => 0, 'point' =>
            endorsements.reject{|e| e.prez == ''}.map{|e| point_for_graph(e)} +
            # fake_points +
            [ { 'x' => -71.0, 'y' => ll_from_xy(40, 100 - 7)[1], 'value' => Math.sqrt(2_100_000), 'bullet_alpha' => 0 }, ] # sets the max size
          },
          { 'gid' => 1, 'title' => 'Endorsement Legend', 'point' => summary_points(endorsements, endorsement_bins)},
          { 'gid' => 2, 'title' => 'Circulation Legend', 'point' => [
              { 'x' =>  -71.0, 'y' => ll_from_xy(40, 100 - 7)[1], 'value' => Math.sqrt(2_100_000), 'bullet_alpha' => 0 },
              # { 'x' => -118.4, 'y' => 33.93,                      'value' => Math.sqrt(  773_884), 'content' => 'Circulation 250,000', 'bullet' => 'square' },
              { 'x' => ll_from_xy(1345-150,  94 - 7)[0], 'y' => ll_from_xy(40, 212 - 7)[1], 'value' => Math.sqrt(  500_000), 'content' => '500k' },
              { 'x' => ll_from_xy(1345-150,  94 - 7)[0], 'y' => ll_from_xy(40, 175 - 7)[1], 'value' => Math.sqrt(   25_000), 'content' => '25k' },
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
  yval_for_mv = { 3=>105, 1 => 80, -1 => 55, -3 => 30 };
  prez_for_mv = { 3=>'Obama', 1 => 'Obama',         -1 => 'McCain',       -3 => 'McCain' };
  prev_for_mv = { 3=>'Bush',  1 => 'Kerry/none', -1 => 'Bush/none', -3 => 'Kerry' };
  [3, 1, -1, -3].each do |mv|
    lng = -78.0
    lat = ll_from_xy(33, yval_for_mv[mv] - 4)[1]
    legend_popup  = "%s (%s in '04)<br/>%s papers, ~%s circ."%       [prez_for_mv[mv], prev_for_mv[mv], endorsement_bins[mv][:papers].length, endorsement_bins[mv][:millions_circ], ]
    label_text    = "%s (%s '04) %s/~%s tot."% [prez_for_mv[mv], prev_for_mv[mv], endorsement_bins[mv][:papers].length, endorsement_bins[mv][:millions_circ], ]
    legend_points << point_for_graph({ :lng => lng, :lat => lat, :movement => mv, :circ =>  7500 }, legend_popup )
    puts "<label> <x>!242.0</x> <y>!#{yval_for_mv[mv]}</y> <text>#{label_text}</text> <align>left</align> <text_size>13</text_size> <text_color>444444</text_color> </label>"
  end
  legend_points
end

#
# Extract the endorsements
#
PROCESS_DATE = '20081019'
raw_filename       = "rawd/endorsements-raw-#{PROCESS_DATE}.txt"
tsv_out_filename   = "fixd/endorsements-cooked-#{PROCESS_DATE}.tsv"
graph_xml_filename = "fixd/endorsements-graph-#{PROCESS_DATE}.xml"
endorsements = get_endorsements(raw_filename)
puts "Writing to intermediate file #{tsv_out_filename}"
File.open(tsv_out_filename, 'w') do |tsv_out|
  tsv_out << Endorsement.members.map{|s| s.capitalize}.join("\t") + "\n"
  endorsements.each do |paper, endorsement|
    tsv_out << endorsement.to_a.join("\t")+"\n"
  end
end

#
# Create the table of endorsements
#
def td el, width=0, html_class=nil, style=nil
  html_class = html_class ? " class='#{html_class}'" : ''
  style      = style      ? " style='#{html_class}'" : ''
  "%-#{width+9+html_class.length}s" % ["<td#{html_class}>#{el}</td>"]
end
def table_headings
  "<tr><th scope='col'>"+ [
    "Circ. Rk", "Paper", "City", "Circulation", "2008 Endorsement", "2004 Endorsement"
    ].join('</th><th scope="col">') + "</th></tr>"
end
def table_row e
  city_st = "#{e.city}, #{e.st}"
  '    <tr>' + [
    (e.rank == 0 ? td('-', 3) : td(e.rank, 3)),
    td(e.paper,35), td(city_st, 40),
    td( (e.circ == 0 ? '(unknown)' : e.circ), 9),
    td(e.prez,6), td(e.prez04, 6),
    td("%6.1f"%e.lat, 6, :lat), td("%6.1f"%e.lng, 6, :lng),
  ].join('') + '</tr>'
end
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
# Sort all newspapers by their endorsed status
#
endorsement_bins = {
  nil => {:papers => [], :total_circ => 0, :title => 'Top 100 papers (by circulation) that have not yet endorsed a candidate', },
   -3 => {:papers => [], :total_circ => 0, :title => 'Endorsing Sen. McCain (and endorsed Kerry in 2004)', },
   -2 => {:papers => [], :total_circ => 0, :title => 'Endorsing Sen. McCain (no endorsement in 2004)',     },
   -1 => {:papers => [], :total_circ => 0, :title => 'Endorsing Sen. McCain (and endorsed Bush or none in 2004)',  },
    3 => {:papers => [], :total_circ => 0, :title => 'Endorsing Sen. Obama (endorsed Bush in 2004)', },
    2 => {:papers => [], :total_circ => 0, :title => 'Endorsing Sen. Obama (no endorsement in 2004)',     },
    1 => {:papers => [], :total_circ => 0, :title => 'Endorsing Sen. Obama (endorsed Kerry or none in 2004)',  },
}
endorsements.sort_by{|paper, e| [-e.circ.to_i, e[:st], e[:paper].gsub(/^The /,'')]}.each do |paper,e|
  bin = case e.movement when -2 then -1 when 2 then 1 else e.movement end
  if (!e.st) || (!e.lat) then p e  end
  endorsement_bins[bin][:papers]     << e
  endorsement_bins[bin][:total_circ] += e.circ
end
#
# Dump HTML for endorsement status
#
endorsement_table = ''
endorsement_table << table_headings()
[3, 1, -1, -3, nil].each do |bin|
  vals = endorsement_bins[bin]
  vals[:millions_circ] = '%3.1f'%[vals[:total_circ]/1_000_000.0] + 'M'
  endorsement_table << "  <tr><th colspan='8' scope='colgroup' class='chunk'>#{vals[:title]}: #{vals[:papers].length} papers, #{vals[:millions_circ]} total circulation</th></tr>"
  vals[:papers].each do |endorsement|
    endorsement_table << table_row(endorsement)
  end
  if (vals[:papers] == [])
    endorsement_table << '<tr><td colspan="8" style="text-align:center"><em>(none yet)</em></td></tr>'
  end
end
html_template = File.open('endorsement_graph_template.html').read
html_template.gsub!(/<!-- Endorsement Table Goes Here -->/, endorsement_table)
File.open('endorsement_graph.html','w'){|f| f << html_template}

#
# Run the graph generation
#
dump_hash_for_graph endorsements, graph_xml_filename, endorsement_bins


#
# These
#

# endorsements.sort_by{|paper, e| [(!!e.city ? 0 : 1), e.circ]}.each do |paper, e|
#   puts '  %-45s => [ %3d, %9d, %9d, %9d, %8.3f, %8.3f, "%2s", %-30s %s ],' % [
#     "'%s'"%e.paper, e.rank, e.circ, e.daily, e.sun, e.lat||0, e.lng||0, e.st, "'%s',"%(e.city ? e.city : e.paper.gsub(/^The /, '')), !!e.city
#   ]
# end
