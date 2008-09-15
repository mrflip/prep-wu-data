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

#
# Connect to all the repos we want to import from
#
DataMapper::Logger.new(STDOUT, :debug)
REPOSITORY_DBNAMES = {
  :ics_dev          => 'ics_dev',
  :scaffold_indexes => 'ics_scaffold_indexes',
  # :delicious      => 'ics_social_network_delicious',
}
DataMapper.open_repositories REPOSITORY_DBNAMES, IMW::ICS_DATABASE_CONNECTION_PARAMS

#
# Get the target field names
#
def get_columns repo
  query = %Q{
        SELECT table_name, GROUP_CONCAT(column_name SEPARATOR ',')
          FROM `information_schema`.`columns`
          WHERE `table_schema` = '#{REPOSITORY_DBNAMES[repo]}'
          GROUP BY table_name
  }
  columns_map = { }
  repository(repo).adapter.query(query).map(&:to_a).each do |table, attrs_list|
    columns_map[table] = attrs_list.split(/,/).to_set
  end
  columns_map
end
def get_all_columns()
  column_cache_file = 'ics_import_column_cache'
  columns = File.exist?(column_cache_file) ? YAML.load(File.open(column_cache_file)) : { }
  REPOSITORY_DBNAMES.keys.each do |repo|
    columns[repo] = get_columns(repo) unless columns.include?(repo)
  end
  YAML.dump(columns, File.open(column_cache_file, 'w'))
  columns
end

#
# klass defs
#
association_klasses = [
  [Note,          'datasets', 'noteable'],
  # [Tagging,     'datasets',  'taggable'],
  # [LicenseInfo, 'datasets', 'dataset'],
  [Rating,        'datasets',  'rateable'],
  [Credit,        'datasets',  'dataset'],
  [Linking,       'datasets',  'dataset'],
  [Contributor,   'credits',  'dataset'],
]

# transport_directly = [
#   Contributor,  Link,    Tag,      License,
#   Payload, Field,
# ]
# all_klasses = [Note]
# all_klasses -= [Dataset]

#
# Bring them across
#
columns = get_all_columns()
association_klasses.each do |klass, join_table, join_attr|
  table_name = klass.to_s.underscore.pluralize
  src,       dest       = [:scaffold_indexes, :ics_dev]
  src_db,    dest_db    = REPOSITORY_DBNAMES.values_at(src, dest)
  src_attrs, dest_attrs = [columns[src][table_name], columns[dest][table_name]]
  attrs =  (src_attrs & dest_attrs).to_a
  query = %{
        REPLACE INTO `#{dest_db}`.#{table_name}
                (#{attrs.join(",   ")})
        SELECT #{attrs.map{|a| "t."+a}.join(", ")}
          FROM      `#{dest_db}`.#{join_table} d
          LEFT JOIN `#{src_db }`.#{table_name} t
            ON      d.id = t.#{join_attr}_id
          WHERE            t.#{join_attr}_id IS NOT NULL
  }
  #
  puts query
end


  # [
  # [
  # ["contributors", "uuid,id,name,handle,created_at,updated_at,created_by,updated_by,url,desc,base_trustification"],
  # ["credits", "uuid,id,created_at,updated_at,created_by,updated_by,handle,dataset_id,contributor_id,role,desc,citation"],
  # ["datasets", "uuid,id,name,handle,created_at,updated_at,created_by,updated_by,category,collection_id,is_collection,valuation,metastats,facts,delicious_taggings,base_trust,approved_at,approved_by"],
  # ["fields", "uuid,id,handle,created_at,updated_at,created_by,updated_by,dataset_id,table_id,name,desc,datatype,representation,concepts,constraints,stats"],
  # ["licenses", "uuid,id,name,handle,created_at,updated_at,created_by,updated_by,url,desc"],
  # ["license_infos", "uuid,id,handle,created_at,updated_at,created_by,updated_by,dataset_id,license_id,url,desc"],
  # ["linkings", "uuid,id,handle,created_at,updated_at,created_by,updated_by,linkable_id,link_id,role,linkable_type"],
  # ["links", "uuid,id,full_url,handle,created_at,updated_at,created_by,updated_by,name,file_path,file_time,file_size,file_sha1,tried_fetch,fetched"],
  # ["link_assets", "uuid,id,full_url,handle,created_at,updated_at,created_by,updated_by,name,file_path,file_time,file_size,file_sha1,tried_fetch,fetched"],
  # ["notes", "uuid,id,name,handle,created_at,updated_at,created_by,updated_by,noteable_id,noteable_type,role,desc"],
  # ["payloads", "uuid,id,file_name,file_path,handle,created_at,updated_at,created_by,updated_by,file_date,format,shape,size,stats,signature,signed_by,fingerprint,dataset_id"],
  # ["processings", "id,asset_id,context,asset_type,processed_at,success,result"],
  # ["ratings", "uuid,id,handle,created_at,updated_at,created_by,updated_by,user_id,rateable_id,rateable_type,rating,context,dataset_id"],
  # ["taggings", "uuid,id,handle,created_at,updated_at,created_by,updated_by,context,tag_id,taggable_id,taggable_type,tagger_id,tagger_type"],
  # ["tags", "uuid,id,name,handle,created_at,updated_at,created_by,updated_by"],
  # ["users", "uuid,id,login,handle,created_at,updated_at,created_by,updated_by,prefs,identity_url,name,email,email_is_public,homepage_link,blurb,public_key,email_verification_code,email_verified_at,roles"]],
  # []]
