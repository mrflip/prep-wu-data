#!/usr/bin/env ruby
require 'rubygems'
require 'dm-core'
require 'fileutils'; include FileUtils
require 'imw'; include IMW
require 'imw/dataset'
require 'imw/dataset/asset'
require 'imw/extract/html_parser'
as_dset __FILE__
DataMapper::Logger.new(STDOUT, :debug) # uncomment to debug
DataMapper.setup_remote_connection IMW::ICS_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'ics_scaffold_indexes' })

USEFUL_DATASET_INDEXES = %w[
  http://archive.ics.uci.edu/ml/index.html
  http://bioinformatics.ca/links_directory/index.html
  http://conflate.net/inductio/2008/02/a-meta-index-of-data-sets/index.html
  http://datamob.org/datasets
  http://kdnuggets.com/datasets/index.html
  http://lib.stat.cmu.edu/datasets/index.html
  http://lsrn.org/lsrn/registry.html
  http://okfn.org/wiki/OpenEnvironmentalData
  http://shirleyfung.com/mbdb/index.php
  http://www.chemspider.com/DataSources.aspx
  http://www.ckan.net/images/ckan.sql.gz
  http://www.data360.org/ds_list.aspx
  http://www.dataplace.org/web_data_links.html
  http://www.datawrangling.com/some-datasets-available-on-the-web
  http://www.essex.ac.uk/linguistics/clmt/w3c/corpus_ling/content/corpora/list/index.html
  http://www.grsampson.net/Resources.html
  http://www.inf.ed.ac.uk/resources/corpora/index.html
  http://www.programmableweb.com/apitag/uk
  http://www.readwriteweb.com/archives/where_to_find_open_data_on_the.php
  http://www.statsci.org/datasets.html
  http://www.trustlet.org/wiki/Repositories_of_datasets
  http://shirleyfung.com/mbdb/filter.php?by=all
  http://www.lsrn.org/lsrn/registry.rdf
]

class FilePoolProcessor
  include Asset::Processor
  attr_accessor :assets

  def parse
    results = []
    USEFUL_DATASET_INDEXES.each do |index_url|
      asset = LinkAsset.find_or_create({ :full_url => index_url })
      asset.wget :wait => 0
      asset.update_from_file!
      asset.save
      processed asset, :useful_dataset_index, index_url.to_yaml
      results << asset
    end
  end
end
processor = FilePoolProcessor.new
processor.parse
