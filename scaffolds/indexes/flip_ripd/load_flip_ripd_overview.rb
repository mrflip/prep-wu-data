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

class SimpleProcessor
  include Asset::Processor

  def define_link hsh
    link = Link.find_or_create({ :full_url => hsh['link_url'] }, {
        :name        => hsh['link_title'],
      })
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
    ds.update_attributes hsh.slice('name', 'description', 'category', 'is_collection').merge({:name => hsh['link_title'],})
    ds.attributes.reject!{|k,v| v.blank? }
    ds.set_fact :fact, :collection_id, hsh['collection_id'] unless hsh['collection_id'].blank?
    contributor = contributors[hsh['contributor_handle']]
    tag_strs = hsh['tag_list'].split(/ /).map{|tag| tag.gsub(/[^\w]/, '_') }
    tag_strs.each do |tag_str|
      tag     = Tag.find_or_create({ :name => tag_str })
      tagging = Tagging.find_or_create({
          :tag_id      => tag.id,               :context       => :tags,
          :taggable_id => ds.id,                :taggable_type => ds.class.to_s,
          :tagger_id   => contributor.id,  :tagger_type   => Contributor.to_s,
        })
    end
   
    credit = Credit.find_or_create({
        :dataset_id => ds.id, :contributor_id => contributor.id, :role => hsh['credits']['role'] },
      hsh['credits'].slice('desc', 'citation'))
    ds.save
    ds
  end

  def define_contributor hsh
    contributor = Contributor.find_or_create({
        :handle => hsh['handle']  }, hsh)
  end

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
