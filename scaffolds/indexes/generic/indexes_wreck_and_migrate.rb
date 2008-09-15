#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/.'
require 'rubygems'
require 'imw'; include IMW
require 'imw/dataset'
require 'fileutils'; include FileUtils::Verbose


DataMapper::Logger.new(STDOUT, :debug) # uncomment to debug
DataMapper.setup_remote_connection IMW::ICS_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'ics_scaffold_indexes' })

[Contributor, Credit, Dataset, Field, LicenseInfo, License, Note, Payload, Rating, Tagging, Tag, User, Linking, Link].each do |klass|
  $stderr.puts "Migrating #{klass.to_s}"
  klass.auto_upgrade!
end
DataMapper.auto_upgrade!

# raise "Skipped! Uncomment!"

# load_pool_from_disk(:ripd_root, 'com.delicious/**/*')

# repository(:default).adapter.query('SELECT l.id AS link_id FROM links l LEFT JOIN link_assets la ON l.id = la.id WHERE la.id IS NULL').each do |link_id|
#   if ! LinkAsset.get(link_id)
#     link = Link.get(link_id)
#     # puts link.attributes
#     LinkAsset.create( link.attributes )
#   end
# end

