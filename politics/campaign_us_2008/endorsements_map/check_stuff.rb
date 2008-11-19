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
require 'lib/state_abbreviations'
#

# #
# # #     puts "%-32s\t{ :paper: %-32s :st: '%s',\t:city: %-31s\t}" % ["'#{paper}':", "'#{paper}',", st, "'#{paper}'"]
# #
# #

# # Cities with two or more papers
# #
# city_papers = { }
# Endorsement.all.each do |paper, e|
#   (city_papers[[e.st||'', e.city||'']] ||= []) << e
# end
# city_papers.sort_by{|st_city, es| [ (es.length > 1) ? 1 : 0, st_city] }.each do |st_city, es|
#   # next if es.length <= 1
#   es.each(&:dump_as_hash)
# end


# # Metros with two or more papers
# #
# metro_papers = { }
# Endorsement.all.each do |paper, e|
#   metro = e.metro
#   (metro_papers[ [metro['st']||e.st, metro['city']||e.city] ] ||= []) << e
# end
# metro_papers.sort_by{|st_metro, es| [ st_metro[0], (es.length > 1) ? 1 : 0, st_metro||'' ] }.each do |st_metro, es|
#   # next if es.length <= 1
#   es.each{|e| e.dump_as_hash }
# end

years =  [1992, 1996, 2000, 2004, 2008,]
st_es        = { 1992 => {}, 1996 => {}, 2000 => {}, 2004 => {}, 2008 => {}, }
total_circ   = { 1992 => {}, 1996 => {}, 2000 => {}, 2004 => {}, 2008 => {}, }
total_pprs = { 1992 => {}, 1996 => {}, 2000 => {}, 2004 => {}, 2008 => {}, }
Endorsement.all.each do |paper, e|
  state = STATE_ABBREVIATIONS.invert[e.st]
  years.each do |year|
    (st_es[year][ [e.prez[year]||'', state||''] ]||=[]) << e
    total_circ[year][e.prez[year]]||=0
    total_pprs[year][e.prez[year]]||=0
    total_circ[year][e.prez[year]] += e.circ||0
    total_pprs[year][e.prez[year]] += 1
  end
end

# dump like it is on E&P

[2004].each do |year|
  st_es[year].sort.each do |prez_st, es|
    prez, st = prez_st
    next if es.blank? || prez.blank?
    puts "%s (%s) (%s)" % [st, es.length, prez]
    es.sort_by(&:paper).each do |e|
      city = e.city.blank?         ? '' : " (#{e.city})"
      prev = e.prez[year-4].blank? ? '' : " (#{e.prez[year-4]})"
      circ = (['0',''].include? e[:circ].to_s) ? '' : ': '+e[:circ].to_s
      puts "%s%s%s%s" % [e.paper, city, prev, circ]
    end
    puts ''
  end
end

years.each do |year|
  print "#{year}\t"
  total_circ[year].keys.sort_by{|k| k||'none'}.each{|prez| print "%-7s\t%-15s\t%-7s\t"%[prez||'none',total_circ[year][prez], total_pprs[year][prez]] }
  puts
end
