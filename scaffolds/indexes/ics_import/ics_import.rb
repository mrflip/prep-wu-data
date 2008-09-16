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

DataMapper::Logger.new(STDOUT, :debug)
require 'ics_import_columns'

class InfochimpsImportClumsily
  attr_accessor :src, :dest, :src_db, :dest_db, :columns
  def initialize src, dest
    self.src  = src
    self.dest = dest
    connect_dbs
  end

  #
  # Connect to all the repos we want to import from
  #
  def connect_dbs
    self.columns = get_all_columns()
    self.src_db, self.dest_db = REPOSITORY_DBNAMES.values_at(self.src, self.dest)
  end

  #
  # get the table name and common fields for a given klass
  #
  def table_and_attrs klass
    table_name = klass.to_s.underscore.pluralize
    src_attrs, dest_attrs = [columns[src][table_name], columns[dest][table_name]]
    attrs =  (src_attrs & dest_attrs).to_a
    [table_name, attrs]
  end

  #
  # pull only resources keyed off a given association
  #
  def build_association_query klass, join_table, join_attr, parent_id
    table_name, attrs = table_and_attrs(klass)
    query = %{
        REPLACE INTO `#{dest_db}`.#{table_name}
                (#{attrs.map{|a| "`"+a+"`"}.join(",   ")})
        SELECT #{attrs.map{|a| "`t`.`"+a+"`"}.join(", ")}
          FROM      `#{dest_db}`.#{join_table} d
          LEFT JOIN `#{src_db }`.#{table_name} t
            ON      d.#{parent_id} = t.#{join_attr}
          WHERE                      t.#{join_attr} IS NOT NULL
    }
  end
  def import_association klass, join_table, join_attr, parent_id
    query = build_association_query(klass, join_table, join_attr, parent_id)
    run_query(query)
  end

  #
  # Move all instances of a resource over
  #
  def build_wholesale_query klass
    table_name, attrs = table_and_attrs(klass)
    query = %{
        REPLACE INTO `#{dest_db}`.#{table_name}
                (#{attrs.map{|a| "`"+a+"`"}.join(",   ")})
        SELECT #{attrs.map{|a| "`t`.`"+a+"`"}.join(", ")}
          FROM      `#{src_db }`.#{table_name} t
    }
  end
  def import_wholesale klass
    query = build_wholesale_query(klass)
    run_query(query)
  end

  #
  # datamapper hates nul result queries.
  # filter exception 'undefined method .fields. for nil'
  #
  def run_query query
    raise unless query =~ /REPLACE INTO .ics_dev.\./
    repository(dest).adapter.execute(query)
  end

  #
  # Bring them across
  #

end

#
# klass defs
#
association_klasses = [
  [Note,          'datasets',  'noteable_id',   'id'],
  [Tagging,       'datasets',  'taggable_id',   'id'],
  # [LicenseInfo,   'datasets',  'dataset_id',    'id'],
  [Rating,        'datasets',  'rateable_id',   'id'],
  [Linking,       'datasets',  'linkable_id',   'id'],
  [Credit,        'datasets',  'dataset_id',    'id'],
  [Link,          'linkings',  'id',            'link_id'],
  [Contributor,   'credits',   'id',            'contributor_id'],
  # fields
  # licenses
  # payloads
  #
]
wholesale_klasses = [
  Tag,
]

[:scaffold_indexes, :delicious].each do |src|
  importer = InfochimpsImportClumsily.new(src, :ics_dev)
  association_klasses.each  do |klass, join_table, join_attr, parent_id|
    # puts '', '','*'*75, klass.to_s, '*', ''
    importer.import_association(klass, join_table, join_attr, parent_id)
  end
  wholesale_klasses.each do |klass|
    importer.import_wholesale klass
  end
  run_query(%{ UPDATE `ics_dev`.taggings SET context = 'tags' })
end
