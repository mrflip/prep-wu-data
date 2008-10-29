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


# NEWSPAPER_CIRC_BL   = YAML.load(File.open("data/newspapers_burrelles_luce.yaml"))
# ENDORSEMENTS        = [2008,2000,1996].map{|year| "data/endorsements_#{year}_eandp.yaml"}
ENDORSEMENT_FILENAMES = [1992, 2008, 2000, 1996].map{|year| "data/endorsements_#{year}_eandp.yaml"} + [
  "data/endorsements_2004_wikipedia.yaml", "data/newspaper_cities.yaml"
]
ENDORSEMENT_LISTS = ENDORSEMENT_FILENAMES.map{|fn| YAML.load(File.open(fn)) }
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

Endorsement.all = { }
ENDORSEMENT_LISTS.each do |endorsement_objs|
  endorsement_objs.each do |paper, hsh|
    if (e = Endorsement[paper])
      e.check_merge! hsh
    else
      Endorsement.add Endorsement.from_hash(hsh)
    end
  end
end
Endorsement.dump :literalize_keys => false, :format => :tsv

CityMetro.load
Endorsement.load :literalize_keys => false, :format => :tsv

def dump_as_hash e, fudge_city=nil
  st, city, paper = e.values_of(:st, :city, :paper)
  paper.gsub!(/\'/, "''")
  prezzes = e.prez.sort.map{|k,v| k if v }
  city = paper if fudge_city && city.blank?
  puts "%-38s { :sun: %d, :paper: %-38s :st: '%s', :city: %-31s } # %s" % ["'#{paper}':", e.sun||1, "'#{paper}',", st, "'#{city}'", prezzes.compact.join(',')]
end

Endorsement.all.sort_by{|paper, e| [e.paper, e.st||'', e.city||'' ]}.each do |paper, e|
  st, city, paper = e.values_of(:st, :city, :paper)
  next if (!city.blank?) || (paper == 'USA Today')
  puts "%-32s\t{ :paper: %-32s :st: '%s',\t:city: %-31s\t}" % ["'#{paper}':", "'#{paper}',", st, "'#{paper}'"]
end

# Geolocation.load
# Endorsement.all.sort_by{|paper, e| [e.sun||('-1'), e.st||'', e.city||'', e.paper, ]}.each do |paper, e|
#   next if Geolocation[e.st, e.city] ||  (paper == 'USA Today')
#   dump_as_hash e, true
# end

# city_papers = { }
# Endorsement.all.each do |paper, e|
#   (city_papers[[e.st||'', e.city||'']] ||= []) << e
# end
# city_papers.sort_by{|st_city, es| st_city }.each do |st_city, es|
#   next unless es.length > 1
#   es.each{|e| dump_as_hash(e) }
# end

Endorsement.all.each do |paper, e|
  e.metro = CityMetro[e.st, e.city] || CityMetro.new
end


Endorsement.all.sort_by{|paper, e| [e.metro.metro_name||'', e.city||'', e.st||'', e.paper, ]}.each do |paper, e|
  # next unless (e.prez[2008] || e.prez[2004] || e.prez[2000])
  prezzes = e.prez.sort.map{|k,v| k if v }
  # puts "%-38s\t%s\t%-31s\t%-61s\t%10s\t%s" % ["'#{paper}':", e.st, "'#{e.city}'", "'#{e.metro.metro_name}'", e.metro.pop_2007, prezzes.join("\t")]
end





# 'Daily Herald':                         { :paper: 'Daily Herald',                      :st: 'IL', :city: 'Arlington Heights',  }"
# -123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789
# next if e.prez[2008] && e.prez[1996]
#
# puts "%-2s\t%-20s\t%-36s\t%s" % [st, city, paper, prezzes.join("\t")]
