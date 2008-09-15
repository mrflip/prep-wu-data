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

#
# Connect to all the repos we want to import from
#
REPOSITORY_DBNAMES = [
  [:ics_dev,           'ics_dev',                      ],
  [:scaffold_indexes,  'ics_scaffold_indexes',         ],
# [:scaffold_indexes,  'ics_social_network_delicious'  ],
]

def open_repositories
  REPOSITORY_DBNAMES.each do |handle, dbname|
    repo_params = IMW::ICS_DATABASE_CONNECTION_PARAMS.merge({ :handle => handle, :dbname => dbname })
    DataMapper.setup_remote_connection repo_params
  end
end

#
# pull all from 2-n into 1
#
class SimpleProcessor
  include Asset::Processor

  def parse
    results = []

    global_attributes = YAML.load(File.open('ripd_datasets_overview.icss.yaml'))
    ripd_datasets_overview_lines = File.open(path_to(:scripts_root, 'scaffolds/indexes/flip_ripd', 'ripd_datasets_overview.txt')).readlines
    ripd_datasets_overview = ripd_datasets_overview_lines.map!{|line| line.split(/\|/).map(&:strip) }
    ripd_datasets_overview.each do |link_url, initial_rating, name, tags_list|
      next if name.blank?
      hsh = {
        'link_url'       => link_url,
        'link_title'     => name,
        'tags_list'      => tags_list,
        'initial_rating' => initial_rating,
      }
      contributors = { hsh['contributor_handle'] => Contributor.first(:handle => hsh['contributor_handle']) }
      dataset     = define_dataset      global_attributes['datasets'].first.merge(hsh), contributors
      link        = define_link         hsh
      define_associations dataset, link

      # ! register as asset
      asset = LinkAsset.find_or_create({ :full_url => link_url })
      asset.wget :wait => 0
      asset.update_from_file!
      asset.save
      processed asset, :flip_ripd_overview, link_url.to_yaml
      results << asset
    end
  end

end

processor = SimpleProcessor.new
processor.parse
