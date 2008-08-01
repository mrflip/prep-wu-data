#!/usr/bin/env ruby
require 'imw/utils'
require 'imw/dataset'
include IMW
as_dset __FILE__, :scaffold => true

#
# Load the full weather station file
#
stations = DataSet.load [:fixd, 'ncdc_weather_stations.yaml']
stations.report(:country_code_wmo)

#
# Save a YAML file with only the US stations
#
us_stns = stations.reject{ |stn| stn[:country_code_wmo] != 'US' }
DataSet.dump us_stns, [:fixd, 'ncdc_weather_stations-US.yaml']

#
# Load the points of interest file
#


#
# Only stations within X miles
#

