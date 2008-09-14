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

# '%data%' '%stats%' '%statistic%'
DATASET_PAGES = %Q{
SELECT COUNT(*) AS `tagging_count`, t.name AS `tag_name`, d.handle AS `asset_url`, d.name AS `asset_name`, d.facts
  FROM          tags t
  LEFT JOIN taggings tg ON tg.tag_id = t.id
  LEFT JOIN datasets d  ON tg.taggable_id = d.id
  WHERE         t.name LIKE '%data%'
    OR          t.name LIKE '%statistics%'
    OR          t.name LIKE '%stats%'
  GROUP BY      d.id
  ORDER BY      tagging_count DESC, t.name
}

ALLURLS_NAMES = %Q{
SELECT d.id AS dataset_id, d.handle AS full_url, MD5(d.handle) AS delicious_link_id, d.name AS asset_name, la.id AS asset_id
  FROM          datasets d
  LEFT JOIN     link_assets la ON la.full_url LIKE CONCAT('%',MD5(d.handle),'%')
  WHERE la.id    IS NOT NULL
    AND la.name  = ''
}

#
class DeliciousAssetsScraper
  def parse asset
    asset.wget :wait => 10
  end
end

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

  def assets_to_parse
    repository(:default).adapter.query(DATASET_PAGES).map do |results|
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

# [Contributor, Credit, Dataset, Field, LicenseInfo, License, Note, Payload, Rating, Tagging, Tag, User, Linking, Link].each{|klass| klass.all.each(&:destroy) }

processor = FilePoolProcessor.new
# processor.unprocess_all :scrape
# processor.parse
# processor.fix_names

#ac85ce1950f100c8874a9461cd8093cc
#123456789_123456789_123456789_12
