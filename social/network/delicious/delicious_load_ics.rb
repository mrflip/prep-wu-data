#!/usr/bin/env ruby
require 'rubygems'
require 'dm-core'
require 'fileutils'; include FileUtils
require 'imw'; include IMW; IMW.verbose = true
require 'json'
require 'yaml'
require  File.dirname(__FILE__)+'/delicious_link_models.rb'
as_dset __FILE__


# IMW::DataSet.setup_remote_connection IMW::ICS_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'ics_dev', :handle => :ics })



