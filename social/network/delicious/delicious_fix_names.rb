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
# DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup_remote_connection IMW::ICS_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'ics_social_network_delicious ' })

ALLURLS_NAMES = %Q{
SELECT d.id AS dataset_id, d.handle AS full_url, MD5(d.handle) AS delicious_link_id, d.name AS asset_name, la.id AS asset_id
  FROM          datasets d
  LEFT JOIN     link_assets la ON la.full_url LIKE CONCAT('%',MD5(d.handle),'%')
  WHERE la.id    IS NOT NULL
    AND la.name  = ''
}

class FilePoolProcessor
  include Asset::Processor
  attr_accessor :assets
  def fix_names
    repository(:default).adapter.query(ALLURLS_NAMES).each do |results|
      dataset_id, full_url, delicious_link_id, asset_name, asset_id = results.to_a
      delicious_link_url = "http://delicious.com/url/#{delicious_link_id}?detail=3&setcount=100&page=1"
      asset = LinkAsset.get(asset_id)
      if asset
        asset.update_attributes :name => asset_name
        puts [delicious_link_id, asset.name].to_json
      else
        puts "no: #{delicious_link_url}"
      end
    end
  end
end
processor = FilePoolProcessor.new
processor.fix_names
