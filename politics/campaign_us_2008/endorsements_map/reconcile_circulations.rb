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
# Oddities:
# -- amarillo Globe-news
#

RAW_FILENAME  = 'ripd/newspaper_circulations_raw.yaml'
DUMP_FILENAME = 'data/newspaper_circulations.yaml'
#
# is there a match from teh fas-fax to the existing endorsement info
#
REJECT_MATCH = [
  ['Las Vegas',   'Sun',     'Las Vegas Review Journal'],  ['Las Vegas',   'Review Journal', 'Las Vegas Sun'],
  ['Coshocton',   'Tribune', 'McCook Daily Gazette'],      ['McAllen',     'La Frontera',    'Gunnison Country Times'],
  ["Chattanooga", "Times",   "Chattanooga Free Press" ],   ["Chattanooga", "Free Press",     "Chattanooga Times" ],
  ["Jonesboro",   "Sun",     "Danville Register and Bee"],


]
def score_match ff, e
  return({:rejected=>true}) if REJECT_MATCH.include?([ff[:city], ff[:paper], e[:paper]])
  match = { }
  [:paper, :circ, :city].each{|attr| match[attr] = (ff[attr] == e[attr] )}
  match[:paper_re] = /#{ff[:paper].gsub(/\W+/, ".+")}/i.match(e.paper)
  # match[:city_re]  = /#{ff[:city ].gsub(/\W+/, ".+")}/i.match(e.city)
  p [match, ff, e] if (e.paper =~ /orange/i) && (ff[:paper] =~ /orange/i)
  case
  when (match[:paper]&&match[:circ]&&match[:city]) then match[:exact] = true
  when (match[:circ])                              then match[:circ] = true; warn ("%-23s %20s,%23s]"%[q_d(ff[:city]), q_d(ff[:paper]), q_d(e[:paper])]) if !match[:paper_re]
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
ff_infos = YAML.load(File.open(RAW_FILENAME))

ff_infos = ff_infos.map{|ff| Hash.zip([:paper, :circ, :city], ff) }.sort_by{|ff| -ff[:circ]}
ff_infos.each{|ff| ff[:circ] = ff[:circ].to_i}
ee_infos = Endorsement.all.values.sort_by{|e| -e.circ.to_i}
ee_infos.map(&:fix!)

def rr_circ ff, e, match
  # "- "Oklahoman":                                [ "Oklahoman",                                201771,         "Oklahoma City"             ]"
  #  123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-
  "- %-44s [ %-44s %7d %-28s ] # %s\n" % [q_d(e[:paper],':'), q_d(ff[:paper]), ff[:circ], q_d(ff[:city],""), matches_of(match).join("-")]
end

File.open(DUMP_FILENAME, 'w') do |dump_file|
  ff_infos.each do |ff|
    found = false
    ee_infos.each do |e|
      match = score_match(ff, e)
      case
      when match[:exact] || match[:good] || match[:circ]
        dump_file << rr_circ(ff, e, match)
        e.circ = ff[:circ] unless e.circ && (e.circ > 0)
        ee_infos.delete(e)
        found = true
        break
      end
    end
    # puts rr_circ(ff, {:paper=>'-',:circ=>0,:city=>'-'}) if !found
  end
end
Endorsement.dump
