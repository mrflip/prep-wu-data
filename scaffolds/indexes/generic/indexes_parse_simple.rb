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

# Scrape these:
#
# http://www.lsrn.org/lsrn/registry.rdf
# http://shirleyfung.com/mbdb/filter.php?by=all         
# http://datamob.org/datasets                           *
# http://bioinformatics.ca/links_directory/index.html   *
# http://archive.ics.uci.edu/ml/datasets.html           *

# http://www.ckan.net/images/ckan.sql.gz

PAGE_STRUCTURES = { 
  'http://datamob.org/datasets' => {
    # Datamob is licensed under Creative Commons Attribution-Share Alike 3.0
    # by Lauren Sperber and Sean Flannagan
    
  
  },
  'http://lib.stat.cmu.edu/datasets/index.html' => {
    '/body/dl/dt' => { 
      'a' => [:link_title],
      { 'a'  => :href } => :link_url ,
    },
    '/body/dl/dd' => { 
      'dd' => [:desc]
    }
  },
  'http://kdnuggets.com/datasets/index.html' => { 
    'td/ul/li' => { 
      'a'               => :link_title,
      { 'a'  => :href } => :link_url ,
      ''                => :description,
    }
  },
  'http://kdnuggets.com/datasets/competitions.html' => { 
    'td/ul/li' => { 
      'a'               => :link_title,
      { 'a'  => :href } => :link_url ,
      ''                => :description,
    }
  },
  'http://kdnuggets.com/datasets/kddcup.html' => { 
    'td/ul/li' => { 
      'a'               => :link_title,
      { 'a'  => :href } => :link_url ,
      ''                => :description,
    }
  },
  'http://www.data360.org/ds_list.aspx' => {
    
  },
  'http://www.dataplace.org/web_data_links.html' => {
    'div.newscol/span.arrow_circle_text_links' => { 
      'p' => [:sections],
      'ul' => { 
        'li' => { 
          'a'               => :link_title,
          { 'a'  => :href } => :link_url ,
          ''                => :description,
        },
      }      
    }    
  },
  'http://www.datawrangling.com/some-datasets-available-on-the-web' => {},
  'http://www.essex.ac.uk/linguistics/clmt/w3c/corpus_ling/content/corpora/list/index.html' => {
    'body/a' => {
      ''               => :link_title,
      { ''  => :href } => :link_url ,
      ''               => :description,
    },
  },
  'http://www.statsci.org/datasets.html' => {
    'body/ul.list/li' => {
      'a'               => :link_title,
      { 'a'  => :href } => :link_url ,
      ''                => :description,
    },
  },
  'http://www.trustlet.org/wiki/Repositories_of_datasets' => {
    '#content//#bodyContent//ul.list/li' => {
      'a'               => :link_title,
      { 'a'  => :href } => :link_url ,
      ''                => :description,
    },
  # 'http://kdnuggets.com/datasets/index.html' => {},
  # 'http://lsrn.org/lsrn/registry.html' => {},
  # 'http://www.chemspider.com/DataSources.aspx' => {},
  # 'http://www.grsampson.net/Resources.html' => {},
  # 'http://www.inf.ed.ac.uk/resources/corpora/index.html' => {},
  },
}

# later
# 'http://www.programmableweb.com/apitag/uk' => {
# },
# http://www.ldc.upenn.edu/Catalog/CatalogEntry.jsp?catalogId=LDC2006T06

# meh
# 'http://www.readwriteweb.com/archives/where_to_find_open_data_on_the.php' => { },
#   'http://conflate.net/inductio/2008/02/a-meta-index-of-data-sets/index.html' => {},


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
