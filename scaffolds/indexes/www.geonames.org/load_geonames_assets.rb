#!/usr/bin/env ruby
require 'rubygems'
require 'dm-core'
require 'fileutils'; include FileUtils
require 'imw'; include IMW
require 'imw/dataset'
require 'imw/dataset/asset'
require 'imw/extract/html_parser'
as_dset __FILE__



#
# Extract information from header and prominent page tags
#
GEONAMES_PAGE_STRUCTURE = {
    'ul.list/li' => {
      'a'               => :link_title,
      { 'a'  => :href } => :link_url ,
      ''                => :description,
    },
  }


DataMapper::Logger.new(STDOUT, :debug) # uncomment to debug
DataMapper.setup_remote_connection IMW::ICS_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'ics_scaffold_indexes' })

class SimpleProcessor
  include Asset::Processor

  def define_link hsh
    link = Link.find_or_create({ :full_url => hsh['link_url'] })
    link.update_attributes :name => hsh['link_title']
    link.wget :wait => 0 # this is ok, we only fetch ~1 per site
    link.save
    link
  end

  def define_associations dataset, link
    linking = Linking.find_or_create({:link_id => link.id, :role => 'main',
        :linkable_id => dataset.id, :linkable_type => dataset.class.to_s  })
    linking.save
  end

  def define_dataset hsh, contributors
    # puts '*'*75, hsh.slice(:user_name, :linker_tag_url).to_json
    ds = Dataset.find_or_create({ :handle => hsh['link_url'] })
    ds.attributes = hsh.slice('description', 'category', 'is_collection').merge({:name => hsh['link_title'], :description => hsh['desc']})
    ds.set_fact :fact, :collection_id, hsh['collection_id']
    ds.fact_hash.delete :geonamesorg

    tag_strs = hsh['tag_list'].split(/ /).map{|tag| tag.gsub(/[^\w]/, '_') }
    tag_strs.each do |tag_str|
      tag     = Tag.find_or_create({ :name => tag_str })
      tagging = Tagging.find_or_create({
          :tag_id      => tag.id,               :context       => :tags,
          :taggable_id => ds.id,                :taggable_type => ds.class.to_s,
          :tagger_id   => contributors['flip.infochimps.org'].id,  :tagger_type   => Contributor.to_s,
        })
    end
    geonames_contrib = contributors['http://www.geonames.com']
    credit = Credit.find_or_create({
        :dataset_id => ds.id, :contributor_id => geonames_contrib.id, :role => hsh['credits']['role'] },
      hsh['credits'].slice('desc', 'citation'))
    ds.save
    ds
  end

  def define_contributor hsh
    contributor = Contributor.find_or_create({
        :handle => hsh['handle']  }, hsh)
  end

  def parse asset
    parsings = YAML.load(asset.result).values[0]
    global_attributes = YAML.load(File.open('geonames_template.icss.yaml'))

    parsings.each do |parsing|
      hsh = Hash.zip(parsing.keys.map(&:to_s), parsing.values)
      next if hsh['link_title'].blank?
      contributors = { }
      global_attributes['contributors'].each do |contributor_hsh|
        contributors[contributor_hsh['handle']] = define_contributor(contributor_hsh)
      end
      dataset_hsh = global_attributes['datasets'].first.merge(hsh).merge({'tag_list' => 'gis geography geographic geonames geolocation place names international' })
      dataset     = define_dataset dataset_hsh, contributors
      link        = define_link    hsh
      define_associations dataset, link
    end
  end

end

class FilePoolProcessor
  include Asset::Processor
  attr_accessor :assets

  def assets_to_parse
    link = LinkAsset.find_or_create :full_url => 'http://www.geonames.org/data-sources.html'
    [link]
  end

  def parse
    html_parser = HTMLParser.new(GEONAMES_PAGE_STRUCTURE)
    self.assets = process(assets_to_parse, :geonames_datasources, html_parser)
  end

  def assets_to_post_process
    Processing.all({ :context=> :geonames_datasources })
  end

  def post_process
    post_processor = SimpleProcessor.new
    process(assets_to_post_process, :post_geonames_datasources, post_processor)
  end

end
processor = FilePoolProcessor.new
processor.parse
processor.post_process



