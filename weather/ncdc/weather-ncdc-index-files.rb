#!/usr/bin/env ruby
require 'imw/utils'; include IMW
require 'imw/dataset/file_collection_utils'

db_params = IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_weather_ncdc' })
IMW::DataSet.setup_remote_connection db_params

# Daily
daily_dset_clxn  = DatasetFileCollection.find_or_create({ :category => 'weather/ncdc/daily' })
rf_clxn          = RippedFileCollection.find_or_create_from_url 'ftp://ftp.ncdc.noaa.gov/pub/data/gsod', daily_dset_clxn
rf_clxn.bulk_load_listing db_params
# Hourly
hourly_dset_clxn = DatasetFileCollection.find_or_create({ :category => 'weather/ncdc/hourly' })
rf_clxn          = RippedFileCollection.find_or_create_from_url 'ftp://ftp.ncdc.noaa.gov/pub/data/noaa', hourly_dset_clxn
rf_clxn.bulk_load_listing db_params, '\\! \\( -iname "isd-lite" -prune \\) '
# Hourly-lite
hlite_dset_clxn  = DatasetFileCollection.find_or_create({ :category => 'weather/ncdc/hourly_lite' })
rf_clxn          = RippedFileCollection.find_or_create_from_url 'ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-lite', hlite_dset_clxn
rf_clxn.bulk_load_listing db_params
