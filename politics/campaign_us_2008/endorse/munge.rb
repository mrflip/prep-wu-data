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
require 'endorsement'

# Presidential Endorsements by Major Newspapers in the 2008 General Election
# Editor & Publisher
# http://www.editorandpublisher.com/eandp/news/article_display.jsp?vnu_content_id=1003875230
# election 2008 election2008 president general newspaper endorsement politics
# Source data by Dexter Hill and Greg Mitchell Editor & Publisher

# to spot check count
# cat rawd/endorsements-raw-20081020.txt | egrep  '^\(?.[a-z]' | wc -l

def parse_ep_endorsements(raw_filename)
  endorsements = {}
  File.open(raw_filename) do |f|
    3.times do f.readline end
    prez  = 'Obama'
    city  = ''
    state = ''
    f.each do |l|
      l.chomp!
      l.gsub!(/>>+/, '')
      l.gsub!(/Foster.*s Daily/, 'Foster\'s Daily')
      next if l =~ /^\s*$/
      case
      when (l.upcase == l)
        state = l.downcase.gsub(/\s+\([0-9]+\)$/, '')
      when (l == 'JOHN McCAIN')
        prez = 'McCain'
        2.times{f.readline}
      else
        m = /^([^\:]*?)(?: \((B|K|N|N\/A|)\))?:? *([0-9,]+)?$/.match(l)
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
  if (orig_paper =~ /Lowell.*Sun/) ||
     (orig_paper =~ /Stockton.*Record/) ||
     (orig_paper =~ /Daily News.*Los Angeles/)
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
  if ['USA Today'].include?(paper) then city = "[National]"; st = '' ; lng, lat = ll_from_xy(1050, 2000 + 758-75) end # fix position in newspar_mmpao
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
def find_prez04_from_wikipedia endorsement
  wp_prez04 = PREZ04_FROM_WIKIPEDIA[endorsement.paper]
  return unless wp_prez04
  if (wp_prez04 != endorsement.prev)
    if endorsement.prev == ''
      endorsement.prez04 = PREZ04[wp_prez04]
    else
      puts "Mismatch: wp #{wp_prez04} e&p #{endorsement.prez04} for #{endorsement.paper}"
    end
  end
end

#
# XML-able hash for amcharts point
#
def point_for_graph endorsement, content=nil
  hsh = { }
  hsh['content'] = content || popup_text(endorsement)
  hsh['x'], hsh['y'] = [ endorsement[:lng], endorsement[:lat] ]
  hsh['value'] = Math.sqrt(endorsement.circ_with_split)
  # Bullet Appearance
  hsh['bullet_color'] = {
    -3 => 'ff1111', -2 => 'cc7777', -1 => 'cc7777', nil => '888888',
     3 => '1111ff',  2 => '7777cc',  1 => '7777cc',             }[endorsement[:movement]]
  hsh['bullet_alpha'] = {
    -3 => 60, -2 => 60, -1 => 60, nil => 15,
     3 => 60,  2 => 60,  1  => 60,                              }[endorsement[:movement]]
  hsh['bullet'] = {
    -3 => 'round_outline', -2 => 'bubble', -1 => 'bubble', nil => 'round',
     3 => 'round_outline',  2 => 'bubble',  1 => 'bubble',      }[endorsement[:movement]]
  hsh.each{|k,v| puts "Unset value for #{k} in #{hsh['content']}" unless v; }
  hsh
end
#
# Readable text for the popup balloon
#
def popup_text endorsement
  prez = (endorsement.prez == '') ? '(no endorsement yet)' : endorsement.prez
  circ   = endorsement.circ_as_text
  prez04 = endorsement.prez04 == '' ? '--' : endorsement.prez04
  "%s <br />%s, %s<br />2008: %s 2004: %s<br />circulation %s" % (endorsement.values_of(:paper, :city, :st)+[prez, prez04, circ])
end
#
# XML-able hash for whole amcharts graph
#
def hash_for_graph endorsements, endorsement_bins
  endorsements = endorsements.values.sort_by{|e| -e.circ_with_split } # must be by circ so bubbles don't get buried
  hsh = { 'chart' => { 'graphs' => { 'graph' => [
          # points
          { 'gid' => 0, 'point' =>
            endorsements.map{|e| point_for_graph(e)} +  # .reject{|e| e.prez == ''}
            # fake_points +
            [ { 'x' => -71.0, 'y' => ll_from_xy(40, 100 - 7)[1], 'value' => Math.sqrt(2_100_000), 'bullet_alpha' => 0 }, ] # sets the max size
          },
          { 'gid' => 1, 'title' => 'Endorsement Legend', 'point' => summary_points(endorsements, endorsement_bins)},
          { 'gid' => 2, 'title' => 'Circulation Legend', 'point' => [
              { 'x' =>  -50.0, 'y' => ll_from_xy(40, 100 - 7)[1], 'value' => Math.sqrt(2_100_000), 'bullet_alpha' => 0 },
              # { 'x' => -118.4, 'y' => 33.93,                      'value' => Math.sqrt(  773_884), 'content' => 'Circulation 250,000', 'bullet' => 'square' },
              { 'x' => ll_from_xy(1000-80,  0)[0], 'y' => ll_from_xy(0, 198 - 7)[1], 'value' => Math.sqrt(  500_000), 'content' => '500k' },
              { 'x' => ll_from_xy(1000-80,  0)[0], 'y' => ll_from_xy(0, 175 - 7)[1], 'value' => Math.sqrt(   50_000), 'content' => '50k' },
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
def as_millions(f) '%3.1f'%[ f / 1_000_000.0] + 'M' end
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
    lng, lat = ll_from_xy(1000-xval, yval_for_mv[mv])
    legend_popup  = "Now endorsing %s,<br/>endorsed %s in 2004<br/>%s papers, ~%s circ."% [prez_for_mv[mv], prev_for_mv[mv], tot_p[mv], as_millions(tot_c[mv]), ]
    legend_points << point_for_graph(Endorsement.new('','','',7500,0,0,lat,lng,'','','',mv,''), legend_popup ).merge({ 'bullet_alpha' => 70 })
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

#
# Extract the endorsements
#
PROCESS_DATE = '20081023'
raw_filename       = "rawd/endorsements-raw-#{PROCESS_DATE}.txt"
tsv_out_filename   = "fixd/endorsements-cooked.tsv"
graph_xml_filename = "fixd/endorsements-graph.xml"
endorsements = parse_ep_endorsements(raw_filename)

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
    td(e.circ_as_text, 9),
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
endorsements.sort_by{|paper, e| [-e.circ.to_i, e[:st], e[:paper].gsub(/^The /,'')]}.each_with_index do |paper_e, i|
  paper, e = paper_e
  e.rank = i+1
  bin = case e.movement when -2 then -1 when 2 then 1 else e.movement end
  if (!e.st) || (!e.lat) then p e  end
  endorsement_bins[bin][:papers]     << e
  endorsement_bins[bin][:total_circ] += e.circ_with_split
  #
  #
  find_prez04_from_wikipedia(e)
end
#
# Dump HTML for endorsement status
#
endorsement_table = ''
endorsement_table << table_headings()
[3, 1, -1, -3, nil].each do |bin|
  vals = endorsement_bins[bin]
  endorsement_table << "  <tr><th colspan='8' scope='colgroup' class='chunk'>#{vals[:title]}: #{vals[:papers].length} papers, #{as_millions(vals[:total_circ])} total circulation</th></tr>"
  vals[:papers].each do |endorsement|
    endorsement_table << table_row(endorsement)
  end
  if (vals[:papers] == [])
    endorsement_table << '<tr><td colspan="8" style="text-align:center"><em>(none yet)</em></td></tr>'
  end
end
html_template = File.open('endorsements_map_template.html').read
html_template.gsub!(/<!-- Endorsement Table Goes Here -->/, endorsement_table)
File.open('endorsements_map.html','w'){|f| f << html_template}

#
# Run the graph generation
#
dump_hash_for_graph endorsements, graph_xml_filename, endorsement_bins

#
# Dump as tsv too
#
puts "Writing to intermediate file #{tsv_out_filename}"
File.open(tsv_out_filename, 'w') do |tsv_out|
  tsv_out << Endorsement.members.map{|s| s.capitalize}.join("\t") + "\n"
  endorsements.sort_by{|p,e| -e.circ }.each do |paper, endorsement|
    tsv_out << endorsement.to_a.join("\t")+"\n"
  end
end


#
# These
#

# endorsements.sort_by{|paper, e| [(!!e.city ? 0 : 1), e.circ]}.each do |paper, e|
#   puts '  %-45s => [ %3d, %9d, %9d, %9d, %8.3f, %8.3f, "%2s", %-30s %s ],' % [
#     "'%s'"%e.paper, e.rank, e.circ, e.daily, e.sun, e.lat||0, e.lng||0, e.st, "'%s',"%(e.city ? e.city : e.paper.gsub(/^The /, '')), !!e.city
#   ]
# end
