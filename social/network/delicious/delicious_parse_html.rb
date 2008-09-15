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


DELICIOUS_PAGE_STRUCTURE = {
  '//ul.bookmarks/li' => {
    :id                                                => :delicious_id,                   # (/^(?:[a-z]+-)?([0-9a-f]{32})(?:-.{0,2})$/, '\1')
    { 'div.bookmark/.dateGroup/span', :title }         => :date_tagged,                    # needs to be rolled over
    'div.bookmark/.data/h4/a.taggedlink'               => :link_title,
    { 'div.bookmark/.data/h4/a.taggedlink', :href }    => :link_url,
    'div.bookmark/.data/.savers/a/span'                => :num_delicious_savers,
    'div.bookmark/.data/.description'                  => :description,                    #
    'div.bookmark/div.tagdisplay/ul.tag-chain/li/a/span' => [:tag_strs],                   # ok
    { 'div.bookmark/div.tagdisplay/ul.tag-chain/li.first/a', :href } => :linker_tag_url,   # %r{^/([^/]+)}
    '.meta/a.user/span'                                => :user_name,
  },

  'div.UrlDetail#pagetitleContent' => {
    { 'p#url/a',  :href }                               => :link_url,
    { '//head/link[@title="RSS feed"]', :href }         => :delicious_id,
      'p#savedBy//span'                                 => :num_delicious_savers,
      'h2/a'                                            => :link_title,
  }
}


class DeliciousAssetsHTMLParser < HTMLParser
end

class DeliciousAssetsPostParser

  def define_contributor hsh
    user_url = 'http://delicious.com/' + ( hsh[:user_name] || hsh[:linker_tag_url] || "fuck-#{rand}" )
    user_url.gsub!(%r{//+}, '/')
    contributor = Contributor.find_or_create({
        :handle => user_url
      }, {
        :name   => user_url,
        :url    => user_url,
      })
    contributor.save
    contributor
  end

  def define_dataset hsh, contributor
    # puts '*'*75, hsh.slice(:user_name, :linker_tag_url).to_json
    ds = Dataset.find_or_create({
        :handle => hsh[:link_url]
      }, {
      })
    ds.attributes = {
      :name        => hsh[:link_title],
      :description => hsh[:description],
    }
    ds.set_fact :fact, :delicious_id,           hsh[:delicious_id]
    ds.set_fact :fact, :num_delicious_savers,   hsh[:num_delicious_savers]

    hsh[:tag_strs].each do |tag_str|
      tag     = Tag.find_or_create({ :name => tag_str })
      tagging = Tagging.find_or_create({
          :tag_id => tag.id,                    :context       => :delicious,
          :taggable_id => ds.id,                :taggable_type => ds.class.to_s,
          :tagger_id   => contributor.id,       :tagger_type   => contributor.class.to_s,
        })
    end
    # p ds.attributes
    ds.save
    ds
  end

  def define_link hsh
    link = Link.find_or_create({
        :full_url => hsh[:link_url]
      }, {
        :name        => hsh[:link_title],
      })
    unless link.full_url =~ /delicious.com/
      link.wget :wait => 0 # this is ok, we only fetch ~1 per site
    end
    link.save
    link
  end

  def define_associations dataset, link
    linking = Linking.find_or_create({:link_id => link.id, :role => 'main',
        :linkable_id => dataset.id, :linkable_type => dataset.class.to_s  })
    linking.save
  end

  def parse asset
    parsed = YAML.load(asset.result)
    page_global     = parsed['div.UrlDetail#pagetitleContent']
    delicious_links = parsed['//ul.bookmarks/li']
    page_global_attributes = page_global[0] || {}
    delicious_links.each do |delicious_link|
      delicious_link.reverse_merge! page_global_attributes
      contributor = define_contributor  delicious_link
      dataset     = define_dataset      delicious_link, contributor
      link        = define_link         delicious_link
      define_associations dataset, link
    end
    delicious_links.length.to_s
  end
end

class FilePoolProcessor
  include Asset::Processor
  attr_accessor :assets

  def assets_to_parse
    # asset_query = { :uuid => ['8817d5af79f35447ba3df4cb323ece7a', 'cd8ebf51dcdc5ec0ba032613addb5aa9', '043786c7cf50543e89892ee5b6637498']}
    # asset_query = { :handle.like => '%/url/%page=1' }
    asset_query = { :order => [:id.desc] }
    LinkAsset.all(asset_query)
  end

  def parse
    delicious_parser = DeliciousAssetsHTMLParser.new(DELICIOUS_PAGE_STRUCTURE)
    self.assets = process(assets_to_parse, :delicious, delicious_parser)
  end

  def assets_to_post_process
    # Processing.all({ :context=> :delicious })
    assets_to_parse.map{|asset| Processing.all({ :context => :delicious, :asset_id => asset.id })}.flatten
  end

  def post_process
    post_processor = DeliciousAssetsPostParser.new
    process(assets_to_post_process, :post, post_processor)
  end
end

# [Contributor, Credit, Dataset, Field, LicenseInfo, License, Note, Payload, Rating, Tagging, Tag, User, Linking, Link].each{|klass| klass.all.each(&:destroy) }

processor = FilePoolProcessor.new
# processor.unprocess(:delicious)
# processor.unprocess(:post)
processor.parse
processor.post_process

#ac85ce1950f100c8874a9461cd8093cc
#123456789_123456789_123456789_12
