#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'dm-core'
# require 'imw/extract/hpricot'
require 'imw'; include IMW
require 'imw/dataset'
require 'imw/dataset/asset'
require 'imw/dataset/datamapper'
require 'fileutils' ; include FileUtils
require 'imw/dataset/link/linkish'
as_dset __FILE__

#
# Setup database
#
#DataMapper::Logger.new(STDOUT, :debug) # watch SQL log -- must be BEFORE call to db setup
dbparams = IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_twitter_friends' })
DataMapper.setup_remote_connection dbparams
require 'twitter_profile_model'

IMW::DIRECTORIES[:old_ripd] = 'old_ripd'
IMW::DIRECTORIES[:new_ripd] = 'new_ripd'

class TwitterAsset
  UUID_INFOCHIMPS_ASSETS_NAMESPACE = UUID.sha1_create(UUID_URL_NAMESPACE, 'http://infochimps.org/assets') unless defined?(UUID_INFOCHIMPS_ASSETS_NAMESPACE)
  include Linkish
  def to_file_path_path_part
    self.class.tier_path_segment(super)
  end
  def to_file_path_host_part
    path_to(:old_ripd)
  end
end

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
    User.all(:limit => 10).each do |user|
      puts [user.ripd_file, user.rip_url].to_json
      # asset = LinkAsset.get(asset_id)
      # if asset
      #   asset.update_attributes :name => asset_name
      #   puts [delicious_link_id, asset.name].to_json
      # else
      #   puts "no: #{delicious_link_url}"
      # end
    end
  end
end
processor = FilePoolProcessor.new
processor.fix_names



