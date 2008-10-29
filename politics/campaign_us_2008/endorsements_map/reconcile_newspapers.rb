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
# merge warn on inconsistent vals
#
Endorsement.class_eval do
  def check_merge! e
    self.members.map(&:to_sym).each do |attr|
      next if e[attr].blank?
      self[attr] = e[attr.to_sym] if self[attr].blank?
      warn "Disagreement in #{attr} for #{paper}: '#{self[attr]}' vs '#{e[attr]}' (#{e.to_json})" if (self[attr] != e[attr.to_sym])
    end
  end
end

#
# recyclable dump
#
def dump_as_hash e, fudge_city=nil
  paper   = e.paper.gsub(/\'/, "''")
  puts "%-38s { :st: %4s, :city: %-31s %7d, :paper: %-38s } # %s" % [
    "'#{paper}':", "'#{e.st}'", "'#{e.city}',", e.circ, "'#{e.paper}'", e.endorsement_hist_str]
end

#
# Load endorsements
#
ENDORSEMENT_FILENAMES = [1992, 2008, 2000, 1996].map{|year| "data/endorsements_#{year}_eandp.yaml"} + [
  "data/endorsements_2004_wikipedia.yaml", "data/newspaper_cities.yaml"
]
ENDORSEMENT_LISTS = ENDORSEMENT_FILENAMES.map{|fn| YAML.load(File.open(fn)) }
Endorsement.all = { }
ENDORSEMENT_LISTS.each do |endorsement_objs|
  endorsement_objs.each do |paper, hsh|
    if (e = Endorsement[paper]) then  e.check_merge! hsh
    else  Endorsement.add Endorsement.from_hash(hsh)  end
  end
end

#
# Load top-100
#
YAML.load(File.open("data/newspapers_burrelles_luce.yaml")).each do |paper, info|
  hsh = Hash.zip([:paper, :rank, :daily, :sun], info)
  if (e = Endorsement[paper])
    e.merge!(hsh)
    e.circ = e.daily if (e.circ.to_i == 0)
  else
    Endorsement.add Endorsement.from_hash(hsh)
  end
end

# #
# # Load metros
# #
# CityMetro.load
# Endorsement.all.each do |paper, e|
#   e.metro = CityMetro[e.st, e.city] || CityMetro.new
# end


# #
# # Load geolocations
# #
# Geolocation.load :format => :tsv
# Endorsement.all.sort_by{|paper, e| [e.st||'', e.city||'', e.paper||'', ]}.each do |paper, e|
#   st, city, paper = e.values_of(:st, :city, :paper)
#   next if paper == 'USA Today'
#   if (city.blank?) || (!Geolocation[e.st, e.city]) then dump_as_hash e, true end
# end

# Endorsement.load :literalize_keys => false, :format => :tsv

#
# coerce values
#
Endorsement.all.values.each(&:fix!)

# # dump out for pasting into data/newspaper_cities
# Endorsement.sort_by_circ.each do |paper, e|
#   dump_as_hash e
# end

Endorsement.dump :literalize_keys => false, :format => :tsv
Endorsement.dump :literalize_keys => false, :format => :yaml

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
# city_papers.sort_by{|st_city, es| [es.length, st_city] }.each do |st_city, es|
#   # next if es.length <= 1
#   es.each{|e| dump_as_hash(e) }
# end
#
#
# Endorsement.all.sort_by{|paper, e| [e.metro.metro_name||'', e.city||'', e.st||'', e.paper, ]}.each do |paper, e|
#   # next unless (e.prez[2008] || e.prez[2004] || e.prez[2000])
#   prezzes = e.prez.sort.map{|k,v| k if v }
#   # puts "%-38s\t%s\t%-31s\t%-61s\t%10s\t%s" % ["'#{paper}':", e.st, "'#{e.city}'", "'#{e.metro.metro_name}'", e.metro.pop_2007, prezzes.join("\t")]
# end

