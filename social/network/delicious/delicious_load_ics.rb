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



class DeliciousAssetsPostParser
  def parse asset
  end
end

class FilePoolProcessor
  include Asset::Processor
  attr_accessor :assets

  def asset_query
    # asset_query = { :uuid => ['8817d5af79f35447ba3df4cb323ece7a', 'cd8ebf51dcdc5ec0ba032613addb5aa9', '043786c7cf50543e89892ee5b6637498']}
    asset_query = { }
  end

  def parse
    delicious_parser = DeliciousAssetsHTMLParser.new(DELICIOUS_PAGE_STRUCTURE)
    self.assets = process(LinkAsset.all(asset_query), :delicious, delicious_parser)
  end

  def post_process
    post_processor = DeliciousAssetsPostParser.new
    process(Processing.all({ :context=> :delicious }), :post, post_processor)
  end
end

# [Contributor, Credit, Dataset, Field, LicenseInfo, License, Note, Payload, Rating, Tagging, Tag, User, Linking, Link].each{|klass| klass.all.each(&:destroy) }

processor = FilePoolProcessor.new
# processor.unprocess(:delicious)
# processor.unprocess(:post)
# processor.parse
processor.post_process

#ac85ce1950f100c8874a9461cd8093cc
#123456789_123456789_123456789_12
