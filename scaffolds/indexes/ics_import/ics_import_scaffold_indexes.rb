#!/usr/bin/env ruby
require 'rubygems'
require 'dm-core'
require 'fileutils'; include FileUtils
require 'imw'; include IMW
require 'imw/dataset'
require 'imw/dataset/asset'
require 'imw/extract/html_parser'
# require  File.dirname(__FILE__)+'/delicious_link_models.rb'
as_dset __FILE__

#
# Connect to all the repos we want to import from
#
# DataMapper::Logger.new(STDOUT, :debug)
require 'ics_import_columns'
columns = get_all_columns()

#
# Find all datasets with an interesting tag
#
DATASETS_TO_IMPORT = %{
        REPLACE INTO `ics_dev`.datasets
              (        delicious_taggings,       base_trust,                    approved_at,      approved_by,
                 id,   uuid,   handle,   created_at,   updated_at,   category,   collection_id,   is_collection,   valuation,   metastats,   facts,   created_by,   updated_by)
        SELECT NULL AS delicious_taggings, 20 AS base_trust, UTC_TIMESTAMP() AS approved_at, 1 AS approved_by,
               d.id, d.uuid, d.handle, d.created_at, d.updated_at, d.category, d.collection_id, d.is_collection, d.valuation, d.metastats, d.facts, d.created_by, d.updated_by
          FROM          `ics_scaffold_indexes`.datasets d
}
# Find datasets to import
repository(:scaffold_indexes).adapter.execute(DATASETS_TO_IMPORT)
