#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/.'
require 'rubygems'
require 'imw'; include IMW
require 'datamapper'
require 'imw/dataset'
Dataset.class_eval do
  include DataMapper::Resource
  property      :delicious_taggings,    Integer,                     :index => :delicious_taggings
  property      :base_trust,            Integer
  property      :approved_at,           DateTime
  property      :approved_by,           Integer
end

DataMapper::Logger.new(STDOUT, :debug) # uncomment to debug
DataMapper.setup_remote_connection IMW::ICS_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'ics_dev' })

[Dataset, Credit, Contributor, Note, Linking, Link, Rating, Tagging, Tag, Payload, Field, LicenseInfo, License, User].each do |klass|
  $stderr.puts "Migrating #{klass.to_s}"
  klass.auto_upgrade!
end
DataMapper.auto_upgrade!

