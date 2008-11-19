#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'yaml'; require 'json'
require 'xmlsimple'
require 'imw/utils/extensions/core'
require 'active_support'
require 'action_view/helpers/number_helper'; include ActionView::Helpers::NumberHelper
#
require 'lib/endorsement'
require 'lib/geolocation'
require 'lib/metropolitan_areas'
require 'lib/utils'
#


xml_bargraph_filename   = "web/chart/endorsements-bargraph.xml"

Endorsement.class_eval do
  def all_rank
    Endorsement.interestings.index(self)
  end
  def rev_rank
    Endorsement.interestings.length - all_rank
  end
  def self.interestings
    return @interestings if @interestings
    ints = all.values.find_all(&:interesting?)
    @interestings = ints.find_all{|e| e.circ && (e.circ > 0) }.sort_by{|e| -e.circ }
  end
end

#
# Create sorted series data
#
endorsements = Endorsement.interestings[0..200]

BARGRAPH_COLORS = {
   3 => '#3030DB',  2 => '#9F9FE0',  1 => '#9F9FE0', 0    => '#999999', 'dn' => '#999999',
  -3 => '#DB3030', -2 => '#E1A0A0', -1 => '#E1A0A0', 'ab' => '#999933',}
# A31818 A1BDDF
def make_bargraph_point e, len
  hsh = { 'content' => (-1*e.party_in(2008).to_i()*e.circ),
    'xid'     => (len - e.all_rank),
    'color'   => BARGRAPH_COLORS[e.mv0408||0],
    'description' => "#{e.paper}<br/>Circulation #{e.circ_as_text}#{e.rank_as_text}<br>#{e.endorsement_hist_str(true)}",
  }
  hsh.each{|k,v| if !v then puts "Unset value for #{k} in #{hsh['description']}"; hsh[k] = '' end }
  hsh
end

endorsements_bargraph = { 'chart' => {
    'series' => { 'value' => (0..endorsements.length).map{|i| { 'content' => i, 'xid' => i }}, },
    'graphs' => { 'graph' => [
        {'gid' => 1, 'value' => endorsements.map{|e| make_bargraph_point(e, endorsements.length)  } }
      ]
    }
  }}


#
# write data file
#
File.open(xml_bargraph_filename, 'w') do |f|
  f << XmlSimple.xml_out(endorsements_bargraph, 'KeepRoot' => true)
end
