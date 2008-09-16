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
              (delicious_taggings,                  base_trust,                    approved_at,      approved_by,
                 uuid,   id,   handle,   name,   created_at,   updated_at,   category,   collection_id,   is_collection,   valuation,   metastats,   facts,   created_by,   updated_by)
        SELECT COUNT(*) AS delicious_taggings, 0 AS base_trust, UTC_TIMESTAMP() AS approved_at, 1 AS approved_by,
               d.uuid, d.id, d.handle, d.name, d.created_at, d.updated_at, d.category, d.collection_id, d.is_collection, d.valuation, d.metastats, d.facts, d.created_by, d.updated_by
          FROM      tags     t
          LEFT JOIN taggings tg ON t.id = tg.tag_id
          LEFT JOIN datasets d  ON d.id = tg.taggable_id
          WHERE         t.name LIKE '%semantic%'
            OR          t.name LIKE '%statistics%'
            OR          t.name LIKE '%stats%'
            OR          t.name LIKE '%data%'
          GROUP BY      d.id
          ORDER BY      delicious_taggings DESC
}
# Find datasets to import
repository(:delicious).adapter.execute(DATASETS_TO_IMPORT)
