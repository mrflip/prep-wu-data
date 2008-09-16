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
# Add columns
#
# Dataset.class_eval do
#   # include DataMapper::Resource
# end


DELICIOUS_PAGE_STRUCTURE = {
  '//ul.bookmarks/li' => {
    { 'div.bookmark/.data/h4/a.taggedlink', :href }    => :link_url,
    'div.bookmark/.data/.description'                  => :description,                    #
    { 'div.bookmark/div.tagdisplay/ul.tag-chain/li.first/a', :href } => :linker_tag_url,   # %r{^/([^/]+)}
    '.meta/a.user/span'                                => :user_name,
  },

  'div.UrlDetail#pagetitleContent' => {
    { 'p#url/a',  :href }                               => :link_url,
      'p#savedBy//span'                                 => :num_delicious_savers,
      'h2/a'                                            => :link_title,
  }
}


class DeliciousAssetsHTMLParser < HTMLParser
end

class DeliciousAssetsPostParser
  
  def get_contributor_handle hsh
    user_name   = ( hsh[:user_name] || hsh[:linker_tag_url] )
    user_handle = 'http://delicious.com/' + (user_name.blank? ? '' : user_name)
    [user_handle, user_name]
  end
  
  def fix_dataset global_hsh, local_hsh
    ds = Dataset.first({ :handle => global_hsh[:link_url] }) or return
    ds.num_delicious_savers = global_hsh[:num_delicious_savers]
    
    #
    # Unwind descriptions into a single note
    #
    descriptions_arr = []
    local_hsh.each do |hsh|
      next unless hsh[:description]
      user_handle, user_name = get_contributor_handle hsh
      desc  = '* '+hsh[:description].gsub(/\n/, "\n  ")
      desc += " -- note by \"delicious.com user #{user_name}\":#{user_handle}"
      descriptions_arr << desc
    end
    ds.set_note('delicious_user_descriptions', descriptions_arr.join("\n\n"), 'Descriptions by delicious.com users')
    ds.save
    ds
  end

  def parse asset
    parsed = YAML.load(asset.result)
    page_global     = parsed['div.UrlDetail#pagetitleContent']
    delicious_links = parsed['//ul.bookmarks/li']
    page_global_attributes = page_global[0] || {}
    warn "I only work on URL pages" unless page_global_attributes[:link_url] && page_global_attributes[:num_delicious_savers]
    fix_dataset page_global_attributes, delicious_links
    delicious_links.length.to_s
  end
end

class FilePoolProcessor
  include Asset::Processor
  attr_accessor :assets

  def assets_to_parse
    asset_query = { :handle.like => '%/url/%page=1' }
    # asset_query = { :order => [:id.desc] }
    LinkAsset.all(asset_query)
  end

  def parse
    delicious_parser = DeliciousAssetsHTMLParser.new(DELICIOUS_PAGE_STRUCTURE)
    self.assets = process(assets_to_parse, :del_pass2, delicious_parser)
  end

  def assets_to_post_process
    Processing.all({ :context=> :del_pass2 })
    # assets_to_parse.map{|asset| Processing.all({ :context => :del_pass2, :asset_id => asset.id })}.flatten
  end

  def post_process
    post_processor = DeliciousAssetsPostParser.new
    process(assets_to_post_process, :post_pass2, post_processor)
  end
end

# [Contributor, Credit, Dataset, Field, LicenseInfo, License, Note, Payload, Rating, Tagging, Tag, User, Linking, Link].each{|klass| klass.all.each(&:destroy) }

processor = FilePoolProcessor.new
processor.parse
processor.post_process

#processor.assets_to_parse
