#!/usr/bin/env ruby
require 'rubygems'
require 'dm-core'
require 'fileutils'; include FileUtils
require 'imw'; include IMW
require 'imw/dataset'
require 'imw/dataset/asset'
require 'imw/extract/html_parser'
require 'ics_models'
as_dset __FILE__
DataMapper::Logger.new(STDOUT, :debug) # uncomment to debug
DataMapper.setup_remote_connection IMW::ICS_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'ics_dev' })
PATHS[:site_root] = '../../../../site'

class SimpleProcessor
  include Asset::Processor

  def parse
    load_files = ['initial.icss.yaml', 'initial-infos.icss.yaml']
    load_files.each do |load_file|
      icss = YAML.load(File.open(path_to(:site_root, 'icss', load_file)))
      [Contributor, User, License, Info].each do |klass|
        table_name = klass.to_s.underscore.pluralize
        next if icss[table_name].blank? 
        icss[table_name].each do |hsh|
          define_generic klass, hsh, true
        end
      end
    end
  end

  def define_generic klass, hsh, force=nil
    attrs = klass.new.attributes.keys.map(&:to_s)
    if hsh['id']
      rsrc = klass.find_or_create({ :id => hsh['id']        }, hsh.slice(*attrs))
    else
      rsrc = klass.find_or_create({ :handle => hsh['handle']}, hsh.slice(*attrs))
    end
    rsrc.update_attributes hsh.slice(*attrs) # if force
    rsrc.save
  end

  # def define_link hsh
  #   link = Link.find_or_create({ :full_url => hsh['link_url'] }, {
  #       :name        => hsh['link_title'],
  #     })
  #   link.wget :wait => 0 # this is ok, we only fetch ~1 per site
  #   link.save
  #   link
  # end
  # 
  # def define_associations dataset, link
  #   linking = Linking.find_or_create({:link_id => link.id, :role => 'main',
  #       :linkable_id => dataset.id, :linkable_type => dataset.class.to_s  })
  #   linking.save
  # end
  # 
  # def define_dataset hsh, contributors
  #   
  #   # puts '*'*75, hsh.slice(:user_name, :linker_tag_url).to_json
  #   ds = Dataset.find_or_create({ :handle => hsh['link_url'] })
  #   ds.update_attributes hsh.slice('name', 'description', 'category', 'is_collection').merge({:name => hsh['link_title'],})
  #   ds.attributes.reject!{|k,v| v.blank? }
  #   ds.set_fact :fact, :collection_id, hsh['collection_id'] unless hsh['collection_id'].blank?
  #   contributor = contributors[hsh['contributor_handle']]
  #   tag_strs = hsh['tag_list'].split(/ /).map{|tag| tag.gsub(/[^\w]/, '_') }
  #   tag_strs.each do |tag_str|
  #     tag     = Tag.find_or_create({ :name => tag_str })
  #     tagging = Tagging.find_or_create({
  #         :tag_id      => tag.id,               :context       => :tags,
  #         :taggable_id => ds.id,                :taggable_type => ds.class.to_s,
  #         :tagger_id   => contributor.id,  :tagger_type   => Contributor.to_s,
  #       })
  #   end
  #  
  #   credit = Credit.find_or_create({
  #       :dataset_id => ds.id, :contributor_id => contributor.id, :role => hsh['credits']['role'] },
  #     hsh['credits'].slice('desc', 'citation'))
  #   ds.save
  #   ds
  # end

end

processor = SimpleProcessor.new
processor.parse
