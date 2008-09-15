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

#
class DeliciousAssetsScraper
  def parse asset
    asset.wget :wait => 10
  end
end

require 'delicious_datasets_interesting_to_infochimps'
class FilePoolProcessor
  include Asset::Processor
  attr_accessor :assets
  def assets_to_parse
    delicious_datasets_interesting_to_infochimps.map do |results|
      # unpack struct
      tagging_count, tag_name, asset_url, asset_name, facts = results.to_a
      # build new asset
      delicious_link_id  = Digest::MD5.hexdigest(asset_url)
      delicious_link_url = "http://delicious.com/url/#{delicious_link_id}?detail=3&setcount=100&page=1"
      # puts Dir["/data/ripd/com.delicious/url/*#{delicious_link_id}*+3D1-*"]
      asset = LinkAsset.find_or_create({ :full_url => delicious_link_url })
      asset.update_attributes :name => asset_name, :created_by  => 2
      asset
    end
  end

  def parse
    delicious_parser = DeliciousAssetsScraper.new()
    self.assets = process(assets_to_parse, :scrape, delicious_parser)
  end
end
processor = FilePoolProcessor.new
processor.parse
