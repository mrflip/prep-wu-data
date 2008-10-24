#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'yaml'; require 'json'; require 'fastercsv'
require 'xmlsimple'
require 'imw'; include IMW;
require 'active_support'
require 'enumerator'
require 'set'
require 'action_view/helpers/number_helper'; include ActionView::Helpers::NumberHelper
$: << File.dirname(__FILE__)+'/..'
as_dset __FILE__
#
require 'election_return'
require 'county'

#
# Discrepancies from USA Today to Census
#
SKIP_STATES = %w[AK HI PR CT MA ME NH RI VT ] #
FIXNAMES = {
  ["AK", "Alaska"                               ]  => "AK",
  ["AR", "Saint Francis"                        ]  => "St. Francis",
  ["ID", "Idaho County"                         ]  => "Idaho",
  ["IL", "DeWitt"                               ]  => "De Witt",
  ["IL", "JoDaviess"                            ]  => "Jo Daviess",
  ["IL", "LaSalle"                              ]  => "La Salle",
  ["KY", "LaRue"                                ]  => "LaRue",
  ["LA", "DeSoto"                               ]  => 'De Soto',
  ["LA", "Jeff Davis"                           ]  => 'Jefferson Davis',
  ["LA", "LaSalle"                              ]  => "La Salle",
  ["MN", 'Lac Qui Parle'                        ]  => 'Lac qui Parle',
  ["MO", "LaClede"                              ]  => "LaClede",
  ["MO", "St. Louis County"                     ]  => "St. Louis",
  ["MS", "Jeff Davis"                           ]  => "Jefferson Davis",
  ["MT", "Lewis & Clark"                        ]  => "Lewis and Clark",
  ["NM", "DeBaca"                               ]  => 'De Baca',
  ["NY","Saint Lawrence"                        ]  => 'St. Lawrence',
  ["OK", "LeFlore"                              ]  => "Le Flore",
  ["TX", "De Witt"                              ]  => "DeWitt",
  ["TX", "La Vaca"                              ]  => "Lavaca",
  ["KY", "LaRue"                                ]  => "Larue",
  ["MO", "LaClede"                              ]  => "Laclede",
  ["NY", "Brooklyn"                             ]  => "Kings",
  ["NY", "Manhattan"                            ]  => "New York",
  ["NY", "Staten Island"                        ]  => "Richmond",
}
# need to combine these with their parent counties
WEIRD = {
  "CO" => ["Broomfield"], # http://quickfacts.census.gov/qfd/states/08/08014.html
  "VA" => ["Clifton Forge"]
}

# Note that the map in this article, taken from the official United States Census
# Bureau site, includes Clifton Forge as an independent city. This reflected the
# political reality at the time of the 2000 Census. However, in 2001, Clifton
# Forge relinquished its city charter and reincorporated as a town in Alleghany
# County, as in Virginia, all municipalities incorporated as towns are included
# within counties.

#
# Load USA Today results
#
tsv_in_filename = 'election_returns_2004.tsv'
ers = ElectionReturn.load(tsv_in_filename) # [1..300]
ers.each do |er|
  if (new_county = FIXNAMES[ [er.st, er.county] ])
    er.county = new_county
  end
  if er.st == 'NV'
    er.county.gsub!(/ County$/, '')
  end
end
ers.reject!{|er| SKIP_STATES.include?(er.st)}

#
# Load counties
#
counties = YAML.load(File.open(path_to(:fixd, 'county_pop_info.yaml')))
SKIP_STATES.each{|st| counties.delete(st)}

#
# Find counties in er's that aren't in census records
#
er_st_counties = { }; counties.keys.each{|st| er_st_counties[st] = Set.new() }
ers.each do |er|
  er_st_counties[er.st] << er.county
end

er_st_counties.each do |st, er_counties|
  county_names = counties[st].keys.to_set - st
  er_counties = er_counties - WEIRD[st].to_set if WEIRD[st]
  extras_in_ers = er_counties - county_names
  extras_in_cts = county_names - er_counties
  unless extras_in_cts.blank? && extras_in_ers.blank?
    puts "%s\t%s\t%s" % [extras_in_ers.length, st, extras_in_ers.to_a.sort.to_json]
    puts "%s\t%s\t%s" % [extras_in_cts.length, st, extras_in_cts.to_a.sort.to_json]
    extras_in_ers.each do |county|
      puts '  ["%s", %-40s]  => %s' % [st, "\"#{county}\"", "\"#{county}\","]
    end
  end
end



# def pct(num) number_to_percentage(100*num, :precision => 0) end
# #
# # XML-able hash for amcharts point
# #
# def point_for_graph election_return, idx, content=nil
#   hsh = { }
#   hsh['content']     = content || popup_text(election_return)
#   hsh['x'], hsh['y'] = [ election_return.total, election_return.blue_margin ]
#   hsh['value']       = Math.sqrt(idx) # election_return.blue_margin
#   # Bullet Appearance
#   hsh['bullet_color'] = election_return.color
#   hsh['bullet_alpha'] = 60
#   hsh['bullet']       = 'round'
#   hsh.each{|k,v| puts "Unset value for #{k} in #{hsh['content']}" unless v; }
#   hsh
# end
# #
# # Readable text for the popup balloon
# #
# def popup_text er
#   txt = "%s county, %s<br />Kerry Margin %s<br />" % [er.county, er.st, pct(er.blue_margin)]
#   [:kerry, :bush, :nader].each do |cand|
#     txt += "%s %s (%s)<br/>" % [cand.to_s.capitalize, er[cand], pct(er.margin(cand))]
#   end
#   txt
# end
# #
# # XML-able hash for whole amcharts graph
# #
# def hash_for_graph election_returns
#   puts election_returns.find_all{|er| er.total != er.total.to_i }.to_yaml
#   election_returns = election_returns.sort_by{|er| -er.total } # must be by bubble size so bubbles don't get buried
#   hsh = { 'chart' => { 'graphs' => { 'graph' => [
#           # points
#           { 'gid' => 0, 'point' =>
#             election_returns.enum_with_index.map{|e,i| point_for_graph(e,i)}
#           },
#         ]}}}
#   XmlSimple.xml_out hsh, 'KeepRoot' => true
# end
# #
# # Generate AMCharts graph
# #
# def dump_rank_plot election_returns, graph_xml_filename
#   puts "Writing to graph file #{graph_xml_filename}"
#   File.open(graph_xml_filename, 'w') do |graph_xml_out|
#     graph_xml_out << hash_for_graph(election_returns)
#   end
# end
#
#
# dump_rank_plot(ers, 'fixd/election_returns_ranked.xml')
