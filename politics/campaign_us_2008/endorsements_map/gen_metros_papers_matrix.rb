#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'yaml'; require 'json'
require 'fastercsv'
require 'imw/utils/extensions/core'
require 'active_support'
require 'action_view/helpers/number_helper'; include ActionView::Helpers::NumberHelper
#
require 'lib/endorsement'
require 'lib/geolocation'
require 'lib/metropolitan_areas'
require 'lib/utils'
#

Endorsement.class_eval do
  #
  # The papers we're going to care to look at.
  #
  def self.interestings
    return @interestings if @interestings
    @interestings = all.values.find_all do |e|
      e.metro &&
        ((e.metro.pop_rank||0) <= 30) && ((e.metro.pop_rank||0) > 0) &&
        ((e.circ||0) >= 10_000)
    end
    @interestings = @interestings.sort_by{|e| [e.metro.pop_rank, -e.circ]}
    @interestings
  end

  #
  # How big is each paper within its metro?
  #
  attr_accessor  :rank_in_metro
  cattr_accessor :metro_hist
  def self.find_ranks_in_metros
    self.metro_hist = { }
    interestings.each do |e|
      metro_hist[e.metro.metro_name] ||= 0
      e.rank_in_metro = (metro_hist[e.metro.metro_name] += 1)
    end
  end
end
Endorsement.find_ranks_in_metros

# x-axis           y-axis               pie slice       bubble size
# metro    paper   paper_rk_in_metro    endorsed+year   metro population

COLUMN_TITLES = [
  "Circulation Rank",        "Circulation",  "Circulation Rank in Metro",
  "Metropolitan Area by Population Rank", "Metropolitan Area (full name)", "City",
  #     "Metro Population", "Metro Population Rank",
  "Endorsement-Year",
  "Newspaper + Rank",
  "Newspaper",
]
#
# Dump CSV file
#
FasterCSV.open("web/data/metros_papers_matrix.csv", "w", :col_sep => "\t") do |csv|
  csv << COLUMN_TITLES
  Endorsement.interestings.each do |e|
    # Want to have seen two or more papers
    next unless Endorsement.metro_hist[e.metro.metro_name] >= 2
    # Don't go past the #7 paper in the metro
    next unless e.rank_in_metro <= 4
    e.prez.sort_by{|y,_| -y }.each do |year, prez|
      party = e.prez_party_name(year)
      party = "none" if party == 'abstain' || party == 'unknown'
      csv << [
        "##{e.rank_in_metro}",  e.circ,           e.rank_in_metro,
        "##{e.metro.pop_rank} - #{e.metro.metro_name.gsub(/-.*/,'')}",   e.metro.metro_name, e.city,
        # e.metro.pop_2007, e.metro.pop_rank,
        "#{year}_#{party}",
        "#{e.circ}_#{e.paper}",
        e.paper,
      ]
    end
  end
end


# US Presidential Endorsements for Major Newspapers, 1992-2008
#
# Editor & Publisher + assorted other sources
#
# http://infochimps.org/static/gallery/politics/endorsements_map/endorsements_map.html
#
# newspaper paper endorsement campaign politics president us obama mccain 1992 1996 2000 2004 2008 media population demographics metropolitan metro city
#
# Endorsements for US president by major US newspapers in each election from 1992-2008, along with some demographic information.
