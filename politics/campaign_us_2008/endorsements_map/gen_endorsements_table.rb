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

def sentry_block text, beg_sentry, end_sentry
  %Q{<!-- #{beg_sentry} -->#{text}<!-- #{end_sentry} -->}
end
def sentry_insert! body, text, sentries
  body.gsub!(/#{sentry_block('(.*?)', *sentries)}/, sentry_block(text, *sentries))
end

DATE_SENTRIES  = ['DATE_GOES_HERE', 'DATE_WENT_THERE']
def sentry_insert_date! body
  text = Time.now.strftime("%A, %Y %b %d")
  sentry_insert! body, text, DATE_SENTRIES
end
TABLE_SENTRIES = ['ENDORSEMENT_TABLE_GOES_HERE', 'ENDORSEMENT_TABLE_WENT_THERE']
def sentry_insert_table! body, table
  sentry_insert! body, table, TABLE_SENTRIES
end

#
# Create the table of endorsements
#
def td el, width=0, html_class=nil, style=nil
  html_class = html_class ? " class='#{html_class}'" : ''
  style      = style      ? " style='#{html_class}'" : ''
  "%-#{width+9+html_class.length}s" % ["<td#{html_class}>#{el}</td>"]
end
def pres_endorsement_tds e
  e.prez.sort.map do |yr, prez|
    td(prez, 6, Endorsement.party_color(prez))
  end
end
def table_row e
  if (e.metro && e.metro.metro_stature == 'MSA')
    metro_pop, metro_poprank =  e.metro.values_of(:pop_2007, :pop_rank)
    # short_name = e.metro.metro_nickname
    short_name = e.metro.metro_name.gsub(/([^,-]+)(?:[^,]*), (\w\w).*$/, '\1')
    metro_name = "%s (%s)" % [short_name, e.metro.metro_st]
    penetration = pct(e.circ.to_f / metro_pop)
  else
    metro_name, metro_pop, metro_poprank, penetration = []
  end
  lng_str = e.lng ? ("%6.1f"%e.lng) : ''
  lat_str = e.lat ? ("%6.1f"%e.lat) : ''
  row_html = []
  row_html << '    <tr>'
  row_html += [
    (e.rank == 0 ? td('-', 3) : td(e.rank, 3)),
    td(e.paper,35), td(e.circ_as_text, 9),
    td(metro_name, 30, :hid), td(metro_pop, 6, :hid), td(penetration, 5, :hid),
    td(metro_poprank, 3, :poprk),
    td(e.city_st, 40),
  ]
  row_html += pres_endorsement_tds(e)
  row_html += [ td(lat_str, 6, :lat), td(lng_str, 6, :lng) ]
  row_html << "</tr>\n"
  row_html.join('')
end

#
# Dump HTML for endorsement status
#
endorsement_table = ''
[3, 1, -1, -3, nil].each do |bin|
  vals = Endorsement.endorsement_bins[bin]
  endorsement_table << "  <tr><th colspan='8' scope='colgroup' class='chunk'>#{vals[:title]}: #{vals[:papers].length} papers, #{as_millions(vals[:total_circ])} total circulation</th></tr>"
  vals[:papers].each do |endorsement|
    next unless endorsement.interesting?
    endorsement_table << table_row(endorsement)
  end
  if (vals[:papers] == [])
    endorsement_table << '<tr><td colspan="8" style="text-align:center"><em>(none yet)</em></td></tr>'
  end
end
#
# # Top 100 papers by metro
# endorsement_table << "  <tr><th colspan='8' scope='colgroup' class='chunk'>Top 100 papers w/ Metro pop</th></tr>"
# #reject{|paper, e| e.rank == 0 }.
# endorsements.find_all{|paper, e| e.metro && e.metro.pop_rank }.sort_by{|paper, e| [e.metro.pop_rank, e.all_rank]}.each do |paper, e|
#   endorsement_table << table_row(e)
# end


html_template = File.open('template/endorsements_map_template.html').read
sentry_insert_table! html_template, endorsement_table
sentry_insert_date!  html_template
MAP_OUTPUT_FILENAME = 'web/endorsements_map.html'
puts "Writing to #{MAP_OUTPUT_FILENAME}"
File.open(MAP_OUTPUT_FILENAME,'w'){|f| f << html_template}
