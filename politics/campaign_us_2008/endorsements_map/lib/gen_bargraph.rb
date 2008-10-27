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

class Endorsement < Struct.new(
  :prez, :prev, :rank, :circ, :daily, :sun, :lat, :lng, :st, :city, :paper,
  :movement, :prez04, :all_rank, :metro # don't set these -- will be set from other attrs
  )
  def initialize(*args)
    super *args
    [:circ, :daily, :sun, :movement, :rank, :all_rank].each{|attr| self[attr] = self[attr].to_i }
    [:lat, :lng                                      ].each{|attr| self[attr] = self[attr].to_f }
    self.movement ||= 0
  end


  def self.load(tsv_file)
    File.open(tsv_file).readlines.map do |line|
      self.new( *line.chomp.split(/\t/) )
    end[1..-1]
  end
end

tsv_in_filename         = "fixd/endorsements-cooked.tsv"
xml_bargraph_filename   = "fixd/endorsements-bargraph.xml"

#
# Load file
#
endorsements = Endorsement.load(tsv_in_filename)

#
# Create sorted series data
#
endorsements = endorsements.reject{|e| e.circ==0 }.sort_by{|e| e.circ}[0..-1]
endorsements.each{|e| e.all_rank = endorsements.length - e.all_rank }

BARGRAPH_COLORS = {
   3 => '#3030DB',  2 => '#9F9FE0',  1 => '#9F9FE0', 0 => '#999999',
  -3 => '#DB3030', -2 => '#E1A0A0', -1 => '#E1A0A0' }
# A31818 A1BDDF
def make_bargraph_point e
  rk = (e.rank==0) ? '' : " (##{e.rank})"
  { 'content' => (case e.prez when 'Obama' then -e.circ    when 'McCain' then e.circ   else 0  end),
    'xid'     => e.all_rank,
    'color'   => BARGRAPH_COLORS[e.movement],
    'description' => "#{e.paper}<br/>Circulation #{e.circ}#{rk}<br>2008:#{e.prez}, 2004:#{(e.prez04=='' ? 'none' : e.prez04 )}",
  }
end

endorsements_bargraph = { 'chart' => {
    'series' => { 'value' => (0..endorsements.length).map{|i| { 'content' => i, 'xid' => i }}, },
    'graphs' => { 'graph' => [
        {'gid' => 1, 'value' => endorsements.map{|e| make_bargraph_point(e)  } }
      ]
    }
  }}


#
# write data file
#
File.open(xml_bargraph_filename, 'w') do |f|
  f << XmlSimple.xml_out(endorsements_bargraph, 'KeepRoot' => true)
end
