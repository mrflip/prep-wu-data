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
#
# Oddities:
# -- amarillo Globe-news
#


#
# is there a match from teh fas-fax to the existing endorsement info
#
def score_match ff, e
  match = { }
  [:paper, :circ, :city].each{|attr| match[attr] = (ff[attr] == e[attr] )}
  match[:paper_re] = /#{ff[:paper].gsub(/\W+/, ".+")}/i.match(e.paper)
  # match[:city_re]  = /#{ff[:city ].gsub(/\W+/, ".+")}/i.match(e.city)
  p [match, ff, e] if (e.paper =~ /orange/i) && (ff[:paper] =~ /orange/i)
  case
  when (match[:paper]&&match[:circ]&&match[:city]) then match[:exact] = true
  when (match[:circ])                              then match[:circ] = true
  when (match[:paper_re]&&match[:city])            then match[:good] = true
  else nil
  end
  match
end
def is_match(match)   match.values.inject(false){|v,t| v||t} end
def matches_of(match) match.map{|k,v| k if v}.compact end
#
# Load
#
Endorsement.load :format => :yaml
ff_infos = YAML.load(File.open('data/newspaper_circulations.yaml'))

ff_infos = ff_infos.map{|ff| Hash.zip([:paper, :circ, :city], ff) }.sort_by{|ff| -ff[:circ]}
ff_infos.each{|ff| ff[:circ] = ff[:circ].to_i}
ee_infos = Endorsement.all.values.sort_by{|e| -e.circ.to_i}
ee_infos.map(&:fix!)

ff_infos.each do |ff|
  found = false
  ee_infos.each do |e|
    match = score_match(ff, e)
    case
    when match[:exact]
      # puts "%-39s\t%-31s\t%6s\t%-39s\t%-31s\t%6s\t%s" %(ff.values_at(:paper, :city, :circ)+e.values_of(:paper, :city, :circ)+[matches_of(match)])
      ee_infos.delete(e)
      found = true
      break
    when match[:good] # || match[:circ]
      puts "%-39s\t%-31s\t%6s\t%-39s\t%-31s\t%6s\t%s" %(ff.values_at(:paper, :city, :circ)+e.values_of(:paper, :city, :circ)+[matches_of(match)])
      ee_infos.delete(e)
      found = true
    end
  end
  #puts "%-39s\t%-31s\t%6s\t%-39s\t%-31s\t%6s\t%s" %(ff.values_at(:paper, :city, :circ)+(['']*3)+['-']) if !found
end

ee_infos.each do |e|
  #puts "%-39s\t%-31s\t%6s\t%-39s\t%-31s\t%6s\t%s" %(e.values_of(:paper, :city, :circ)+(['-------']*3)+['-'])
end

# ff_circs.each do |ffpaper, circ, city|
#   # print "%-47s\t%-23s" % [ffpaper, city]
#   Endorsement.all.each do |_, e|
#     if paper_re.match(e.paper) && city_re.match(e.city)
#       # print "%-39s\t%-31s" % [e.paper, e.city ]
#       found_es[e.paper] << [ffpaper, city]
#     end
#   end
#   # puts ''
# end
#
