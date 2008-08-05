#!/usr/bin/env ruby
require 'rubygems'
require 'dm-core'
require 'imw/utils'
require 'imw/dataset/datamapper'
include IMW; IMW.verbose = true
as_dset __FILE__

#
# Setup database
#
require 'twitter_friends_db_definition'; setup_twitter_friends_connection()
require 'twitter_profile_model'

#
# Wipe DB and add new migration
#
DataMapper.auto_migrate!
