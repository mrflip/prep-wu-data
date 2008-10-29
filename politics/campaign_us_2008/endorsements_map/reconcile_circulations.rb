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

Endorsement.load :literalize_keys => false, :format => :tsv
circs = YAML.load(File.open('data/newspaper_circulations.yaml'))

found_es = { }
Endorsement.all.each{|p,e| found_es[p] = [] }

circs.each do |cpaper, circ, city|
  cpaper.gsub!(/ & /, ' and ')
  paper_re = /#{cpaper.gsub(/\W+/, ".+")}/i
  city_re  = /#{city.gsub(/\W+/, ".+")}/i

  # print "%-47s\t%-23s" % [cpaper, city]
  Endorsement.all.each do |_, e|
    if paper_re.match(e.paper) && city_re.match(e.city)
      # print "%-39s\t%-31s" % [e.paper, e.city ]
      found_es[e.paper] << [cpaper, city]
    end
  end
  # puts ''
end

found_es.sort_by{|pp,i| e=Endorsement[pp]; [(e.circ||-1).to_i, e.st||'', e.city||''] }.each do |paper, info|
  e = Endorsement[paper]
  next unless info.blank?
  print "%-39s\t%-31s\t%6d\t" % [e.paper, e.city, e.circ ]
  info.each{|cp, cc|  print "%-47s\t%-23s" % [cp, cc] }
  puts ''
end
