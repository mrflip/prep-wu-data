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

# NEWSPAPER_CIRC_BL   = YAML.load(File.open("data/newspapers_burrelles_luce.yaml"))
# ENDORSEMENTS        = [2008,2000,1996].map{|year| "data/endorsements_#{year}_eandp.yaml"}
ENDORSEMENT_FILENAMES = [
  "data/endorsements_2004_wikipedia.yaml", "data/newspaper_cities.yaml"
] + [2008, 2000, 1996].map{|year| "data/endorsements_#{year}_eandp.yaml"}
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
Endorsement.dump :literalize_keys => false

Endorsement.load :literalize_keys => false

# Endorsement.all.sort_by{|paper, e| [e.paper, e.st||'', e.city||'' ]}.each do |paper, e|
#   st, city, paper = e.values_of(:st, :city, :paper)
#   next if (!city.blank?) || (paper == 'USA Today')
#   puts "%-32s\t{ :paper: %-32s :st: '%s',\t:city: %-31s\t}" % ["'#{paper}':", "'#{paper}',", st, "'#{paper}'"]
# end

Geolocation.load
Endorsement.all.sort_by{|paper, e| [e.st||'', e.city||'', e.paper, ]}.each do |paper, e|
  st, city, paper = e.values_of(:st, :city, :paper)
  # next if Geolocation[st, city] || !e.sun.blank? ||  (paper == 'USA Today')
  paper.gsub!(/\'/, "''")
  puts "%-32s\t{ :sun: %d, :paper: %-32s :st: '%s',\t:city: %-31s\t}" % ["'#{paper}':", e.sun||1, "'#{paper}',", st, "'#{city}'"]
end


# 'Daily Herald':                         { :paper: 'Daily Herald',                      :st: 'IL', :city: 'Arlington Heights',  }"
# -123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789
# next if e.prez[2008] && e.prez[1996]
# prezzes = e.prez.sort.map{|k,v| k if v }
# puts "%-2s\t%-20s\t%-36s\t%s" % [st, city, paper, prezzes.join("\t")]
