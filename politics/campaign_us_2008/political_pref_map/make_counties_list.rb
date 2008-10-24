#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'yaml'
require 'fastercsv'
require 'imw/utils/extensions/core'
#

# Land area and population - saved as USPopulationHousingUnitsAreaAndDensity-ByCounty.tsv
# http://factfinder.census.gov/servlet/GCTTable?_bm=y&-geo_id=01000US&-ds_name=DEC_2000_SF1_U&-_lang=en&-redoLog=false&-format=US-25|US-25S&-mt_name=DEC_2000_SF1_U_GCTPH1_US25&-CONTEXT=gct
# See also
# http://www.census.gov/popest/counties/files/CO-EST2007-ALLDATA.csv

FasterCSV.foreach("path/to/file.csv") do |row|
  # use row here...
end
