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
# Cities with two or more papers
#
# city_papers = { }
# Endorsement.all.each do |paper, e|
#   (city_papers[[e.st||'', e.city||'']] ||= []) << e
# end
# city_papers.sort_by{|st_city, es| [ (es.length > 1) ? 1 : 0, st_city] }.each do |st_city, es|
#   # next if es.length <= 1
#   es.each{|e| dump_as_hash(e) }
# end


# # Metros with two or more papers
# #
# metro_papers = { }
# Endorsement.all.each do |paper, e|
#   metro = e.metro
#   (metro_papers[ [metro['st']||e.st, metro['city']||e.city] ] ||= []) << e
# end
# metro_papers.sort_by{|st_metro, es| [ (es.length > 1) ? 1 : 0, st_metro ] }.each do |st_metro, es|
#   # next if es.length <= 1
#   es.each{|e| dump_as_hash(e) }
# end

st_es = { }
total_circ = { }
total_papers = { }
Endorsement.all.each do |paper, e|
  next unless e.prez_2008
  next if     e.prez_2008 == 'abstain'
  state = STATE_ABBREVIATIONS.invert[e.st]
  (st_es[ [e.prez_2008, state] ]||=[]) << e
  total_circ[e.prez_2008]||=0
  total_papers[e.prez_2008]||=0
  total_circ[e.prez_2008] += e.circ||0
  total_papers[e.prez_2008] += 1
end

# # dump like it is on E&P
#
# st_es.sort.each do |p08_st, es|
#   puts "%s (%s)" % [p08_st[1], es.length]
#   es.sort_by(&:paper).each do |e|
#     city = e.city == '' ? '' : " (#{e.city})"
#     circ = (['0',''].include? e[:circ].to_s) ? '' : ': '+e[:circ].to_s
#     puts "%s%s%s" % [e.paper, city, circ]
#   end
#   puts ''
# end

p [total_circ, total_papers]
