#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'yaml'
require 'fastercsv'
require 'imw/utils/extensions/core'
load '../endorse/state_abbreviations.rb'
#
require 'county'

# Land area and population - saved as USPopulationHousingUnitsAreaAndDensity-ByCounty.tsv
# http://factfinder.census.gov/servlet/GCTTable?_bm=y&-geo_id=01000US&-ds_name=DEC_2000_SF1_U&-_lang=en&-redoLog=false&-format=US-25|US-25S&-mt_name=DEC_2000_SF1_U_GCTPH1_US25&-CONTEXT=gct
# See also
# http://www.census.gov/popest/counties/files/CO-EST2007-ALLDATA.csv

COUNTY_POP_FILENAME = 'ripd/USPopulationHousingUnitsAreaAndDensity-ByCounty/USPopulationHousingUnitsAreaAndDensity-ByCounty.tsv'
COUNTY_YAML_OUT     = 'fixd/county_pop_info.yaml'

# hash by st, county
counties = { }; STATE_ABBREVIATIONS.values.each{|st| counties[st] = { }}
rows = FasterCSV.readlines(COUNTY_POP_FILENAME, :col_sep => "\t")
10.times{ rows.shift }; 2.times{ rows.pop };
while !rows.blank? do
  row = rows.shift
  if row[0].strip == ''
    while rows[0][0].strip == ''; rows.shift end # skip repeated blank lines
    row   = rows.shift
    st = STATE_ABBREVIATIONS[row[0].upcase]
    row[0] = st
  end
  county = County.new(st, *row)
  warn "Duplicate county: #{counties[county.st][county.root_name]} for #{county}" if counties[county.st][county.root_name]
  counties[county.st][county.root_name] = county
end
YAML.dump(counties, File.open(COUNTY_YAML_OUT, 'w'))
# puts County.place_types.to_yaml
