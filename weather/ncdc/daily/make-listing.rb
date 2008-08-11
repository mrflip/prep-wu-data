#!/usr/bin/env ruby
require 'rubygems'
require 'imw/utils';       include IMW; IMW.verbose = true
require 'imw/utils/paths'; as_dset __FILE__
require '../weather-ncdc-dataset-models'
require 'fileutils'

gsod_dset_clxn = DatasetFileCollection.find_or_create({ :category => path_to(:dset) })
RippedFileCollection.index_siterip 'ftp://ftp.ncdc.noaa.gov/pub/data/gsod', gsod_dset_clxn

# #
# # register dataset
# #
# # FIXME -- ick.
# #
# gsod_ripd_clxn = RippedFileCollection.find_or_create({
#     :protocol => 'ftp', :domain => 'ftp.ncdc.noaa.gov', :base_path => '/pub/data/gsod'})
# gsod_ripd_clxn.dataset_file_collection = gsod_dset_clxn
# gsod_ripd_clxn.save
#
# #
# # Surf through a listing of ripped files
# # and record their particulars
# #
# FileUtils.cd path_to(:ripd) do
#   Dir['[0-9][0-9][07-9][0-9]/*.gz'].each do |ripd_path|
#     # Weather specific info
#     m = %r{\d{4}/(\d{6})-(\d{5})-(\d{4})(?:\.op)?\.gz}.match(ripd_path) or
#       (warn ("Bad filename #{ripd_path}") and next)
#     usaf, wban, year = m.captures
#     weather_fileinfo = WeatherRippedFile.find_or_create({
#         :usaf => usaf.to_i, :wban => wban.to_i, :year => year.to_i })
#     # get the generic file info too
#     ripped_file = RippedFile.from_file(ripd_path, gsod_ripd_clxn)
#     weather_fileinfo.ripped_file = ripped_file
#     weather_fileinfo.save
#   end
# end
