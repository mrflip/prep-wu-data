#!/usr/bin/env ruby
require 'imw/utils'
require 'imw/dataset'
include IMW; IMW.verbose = true
as_dset __FILE__, :scaffold => true
add_path :fixd_ncdc, [:fixd_root, 'weather/ncdc']

#
# Load the full weather station file
#
stations = DataSet.load [:fixd_ncdc, 'stations/ncdc_weather_stations-us.yaml']
stations.report Proc.new{|row| (row[:lng]||0).round } , :do_hist => false

#
# Load the points of interest file
#


#
# Only stations within X miles
#

