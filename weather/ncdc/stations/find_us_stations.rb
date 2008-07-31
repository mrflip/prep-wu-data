#!/usr/bin/env ruby
require 'imw/utils'
require 'imw/utils/paths'
require 'imw/workflow/scaffold'
require 'imw/extract'
# require 'fileutils'; include FileUtils::Verbose
require 'YAML'
include IMW

add_path :ripd_root, [:data_root, 'working/ripd']
scaffold_dataset 'weather/ncdc/stations'


#
# Load the full weather station file
#
stations = YAML.load(File.open(path_to(:fixd, 'ncdc_weather_stations.yaml')))

#
# Save a YAML file with only the US stations
#
us_stns = stations.reject{ |stn| stn[:country_code_wmo] != 'US' }
YAML.dump(us_stns, File.open(path_to(:fixd, 'ncdc_weather_stations-US.yaml'), "w"))

#
# Load the points of interest file
#

#--

#
# Only stations within X miles
#

