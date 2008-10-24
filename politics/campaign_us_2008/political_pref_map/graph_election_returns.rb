#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'yaml'; require 'json'; require 'fastercsv'
require 'xmlsimple'
require 'imw'; include IMW;
$: << File.dirname(__FILE__)+'/..'
as_dset __FILE__
#
require 'election_return'

tsv_in_filename = 'election_returns_2004.tsv'
ers = ElectionReturn.load(tsv_in_filename)


#
# XML-able hash for amcharts point
#
def point_for_graph election_return, content=nil
  hsh = { }
  hsh['content']     = content || popup_text(election_return)
  hsh['x'], hsh['y'] = [ election_return.total, election_return.blue_margin ]
  hsh['value']       = Math.sqrt(81) # election_return.blue_margin
  # Bullet Appearance
  hsh['bullet_color'] = 'cc7777'
  hsh['bullet_alpha'] = 60
  hsh['bullet']       = 'round'
  hsh.each{|k,v| puts "Unset value for #{k} in #{hsh['content']}" unless v; }
  hsh
end
#
# Readable text for the popup balloon
#
def popup_text er
  txt = "%s county, %s<br />Kerry Margin %s%%<br />" % [er.county, er.st, er.blue_margin]
  [:kerry, :bush, :nader].each do |cand|
    txt += "%s %s (%s%%)<br/>" % [cand.to_s.capitalize, er[cand], er.margin(cand)]
  end
end
#
# XML-able hash for whole amcharts graph
#
def hash_for_graph election_returns
  puts election_returns.find_all{|er| er.total != er.total.to_i }.to_yaml
  election_returns = election_returns.sort_by{|er| -er.total } # must be by bubble size so bubbles don't get buried
  hsh = { 'chart' => { 'graphs' => { 'graph' => [
          # points
          { 'gid' => 0, 'point' =>
            election_returns.map{|e| point_for_graph(e)}
          },
        ]}}}
  XmlSimple.xml_out hsh, 'KeepRoot' => true
end
#
# Generate AMCharts graph
#
def dump_rank_plot election_returns, graph_xml_filename
  puts "Writing to graph file #{graph_xml_filename}"
  File.open(graph_xml_filename, 'w') do |graph_xml_out|
    graph_xml_out << hash_for_graph(election_returns)
  end
end


dump_rank_plot(ers, 'fixd/election_returns_ranked.xml')
