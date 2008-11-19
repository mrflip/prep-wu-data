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


def sentry_block key, text
  key = key.to_s.upcase
  %Q{<!-- #{key}_GOES_HERE -->#{text}<!-- #{key}_WENT_THERE -->}
end
def sentry_insert! body, key, text
  body.gsub!(/#{sentry_block(key, '(.*?)')}/, text)
end

def sentry_insert_date! body
  date = Time.now.strftime("%A, %Y %b %d")
  sentry_insert! body, :date, sentry_block(:date, date)
end
def sentry_insert_timestamps! body
  timestamp = Time.now.strftime("%Y%m%d%H%M%S")
  sentry_insert! body, :timestamp, timestamp
end
def sentry_insert_text! body, key, text
  sentry_insert! body, key, sentry_block(key, text)
end

#
# Create the table of endorsements
#
def td el, width=0, html_class=nil, style=nil
  html_class = html_class ? " class='#{html_class}'" : ''
  style      = style      ? " style='#{html_class}'" : ''
  "%-#{width+9+html_class.length}s" % ["<td#{html_class}>#{el}</td>"]
end
def tds_for_endorsement e
  e.prez.sort.map do |yr, prez|
    td(prez, 6, Endorsement.party_color(prez))
  end
end
def tds_for_metro e
  if (e.metro && e.metro.metro_name)
    metro_pop     = e.metro.pop_2007
    metro_poprank = e.metro.pop_rank
    short_name    = e.metro.metro_name.gsub(/([^, -]+)(?:[^, ]*), (\w\w).*$/, '\1')
    metro_st      = e.metro.metro_st ? " (#{e.metro.metro_st})" : ''
    metro_name    = "%s%s %s" % [short_name,      metro_st,  e.metro.metro_stature]
    penetration   = metro_pop ? pct(e.circ.to_f / metro_pop) : 0
    metro_pop_str = metro_pop ? ", pop. #{metro_pop}" : ''
    metro_abbr    = %Q{<abbr title='#{metro_name}#{metro_pop_str}'>#{e.city_st}</abbr>}
  else
    metro_pop, metro_poprank, penetration = []
    metro_abbr = e.city_st
  end
  [ td(metro_abbr, 90, :city_st), td(metro_poprank, 3, :poprk)   ]
end
def table_row e
  lng_str = e.lng ? ("%6.1f"%e.lng) : ''
  lat_str = e.lat ? ("%6.1f"%e.lat) : ''
  row_html = []
  row_html << '    <tr>'
  row_html << td(e.rank_as_text, 3)
  row_html << td(e.paper,35)
  row_html << td(e.circ_as_text, 9)
  row_html += tds_for_metro(e)
  row_html += tds_for_endorsement(e)
  row_html += [ td(lat_str, 6, :lat), td(lng_str, 6, :lng) ]
  row_html << "</tr>\n"
  row_html.join('')
end


#
# Stuff the summary labels into the charts.xml
#
def summary_labels
  text = []
  yval_for_mv = { 'O' => 145, 3=>123, 1 => 103, 'M' =>  80, -1 =>  58, -3 =>  38, 'ab' =>  15, nil =>  15 };
  xval_for_mv = { 'O' => 160, 3=>160, 1 => 160, 'M' => 160, -1 => 160, -3 => 160, 'ab' => 177, nil => 100 };

  prez_for_mv = { 3=>'Obama in \'04', 1 => 'Obama in \'04',         -1 => 'McCain in \'04',       -3 => 'McCain in \'04' };
  prev_for_mv = { 3=>'Bush in \'04',  1 => 'Kerry or none in \'04', -1 => 'Bush or none in \'04', -3 => 'Kerry in \'04', 'ab' => 'abstain', nil => 'not yet' };
  tot_p = { }; tot_c = { }; [-3, -1, 1, 3, 'ab', nil].each do |mv|
    tot_p[mv] = Endorsement.endorsement_bins[mv][:papers].length; tot_c[mv] = Endorsement.endorsement_bins[mv][:total_circ]
  end
  [3, 1, -1, -3, 'ab', nil].each do |mv|
    label_text    = prev_for_mv[mv]
    text << "<label> <x>!#{xval_for_mv[mv]-19}</x> <y>!#{yval_for_mv[mv]+5}</y> <text>#{label_text}</text> <align>left</align> <text_size>13</text_size> <text_color>444444</text_color> </label>"
  end

  [ ['O', "%s (%s/~%s tot)"% ['Obama',  tot_p[ 3] + tot_p[ 1], as_millions(tot_c[ 3]+tot_c[ 1]) ]],
    ['M', "%s (%s/~%s tot)"% ['McCain', tot_p[-3] + tot_p[-1], as_millions(tot_c[-3]+tot_c[-1]) ]],
  ].each do |mv, label_text|
    text << "<label> <x>!#{xval_for_mv[mv]+5}</x> <y>!#{yval_for_mv[mv]}</y> <text>#{label_text}</text> <align>left</align> <text_size>13</text_size> <text_color>444444</text_color> </label>"
  end
  text.join("\n")
end


#
# Dump HTML for endorsement status
#
endorsement_table = ''
[3, 1, -1, -3, 'ab', nil, 'dn'].each do |bin|
  vals = Endorsement.endorsement_bins[bin]
  endorsement_table << "  <tr><th colspan='8' scope='colgroup' class='chunk'>#{vals[:title]}: #{vals[:papers].length} papers, #{as_millions(vals[:total_circ])} total circulation</th></tr>\n"
  vals[:papers].each do |endorsement|
    next unless endorsement.interesting?
    endorsement_table << table_row(endorsement)
  end
  if (vals[:papers] == [])
    endorsement_table << %Q{<tr><td colspan="8" style="text-align:center"><em>(none yet)</em></td></tr>\n}
  end
end
#
# # Top 100 papers by metro
# endorsement_table << "  <tr><th colspan='8' scope='colgroup' class='chunk'>Top 100 papers w/ Metro pop</th></tr>"
# #reject{|paper, e| e.rank == 0 }.
# endorsements.find_all{|paper, e| e.metro && e.metro.pop_rank }.sort_by{|paper, e| [e.metro.pop_rank, e.all_rank]}.each do |paper, e|
#   endorsement_table << table_row(e)
# end

#
# The endorsements map page, sorted by 2008 status.
#
 HTML_TEMPLATE_FILENAME = 'template/endorsements_map_template.html'
CHART_TEMPLATE_FILENAME = 'template/chart/chart_settings-map.xml'
 HTML_OUTPUT_FILENAME   = 'web/endorsements_map.html'
CHART_OUTPUT_FILENAME   = 'web/chart/chart_settings-map.xml'
html_template = File.open(HTML_TEMPLATE_FILENAME).read
sentry_insert_text!       html_template, :endorsement_table, endorsement_table
sentry_insert_timestamps! html_template
sentry_insert_date!       html_template
puts Time.now.to_s+" Writing to #{HTML_OUTPUT_FILENAME}"
File.open(HTML_OUTPUT_FILENAME,'w'){|f| f << html_template}

#
# Stuff labels into endorsement map XML settings file.
#
chart_xml_template = File.open(CHART_TEMPLATE_FILENAME).read
sentry_insert_text!       chart_xml_template, :summary_label, summary_labels
sentry_insert_timestamps! chart_xml_template
puts Time.now.to_s+" Writing to #{CHART_OUTPUT_FILENAME}"
File.open(CHART_OUTPUT_FILENAME,'w'){|f| f << chart_xml_template}
