#!/usr/bin/env ruby
require 'rubygems'
require 'dm-core'
require 'imw'
require 'imw/dataset/datamapper'
include IMW
as_dset __FILE__

#
# Setup database
#
# require 'twitter_friends_db_definition'; setup_twitter_friends_connection()

DataMapper::Logger.new(STDOUT, :debug) # watch SQL log -- must be BEFORE call to db setup
dbparams = IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_twitter_friends' })
DataMapper.setup_remote_connection dbparams
require 'twitter_profile_model'

#
# Wipe DB and add new migration
#
# DataMapper.auto_migrate!
# TwitterPageRank.auto_migrate!
