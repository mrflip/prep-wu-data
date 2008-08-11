#!/usr/bin/env ruby
require  File.dirname(__FILE__)+'/weather-ncdc-dataset-models'
require  File.dirname(__FILE__)+'/daily/weather-ncdc-daily-models'
require 'imw/dataset/file_collection'
require 'imw/dataset/datamapper/uri'

#
# Wipe DB and add new migration
#
DataMapper.auto_migrate!
