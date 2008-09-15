
#
# Call columns = get_all_columns() for setup
#

# ===========================================================================

#
# Connect to all the repos we want to import from
#
REPOSITORY_DBNAMES = {
  :ics_dev          => 'ics_dev',
  :scaffold_indexes => 'ics_scaffold_indexes',
  :delicious      => 'ics_social_network_delicious',
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
  column_cache_file = 'ics_import_column_cache.yaml'
  columns = File.exist?(column_cache_file) ? YAML.load(File.open(column_cache_file)) : { }
  REPOSITORY_DBNAMES.keys.each do |repo|
    columns[repo] = get_columns(repo) unless columns.include?(repo)
  end
  YAML.dump(columns, File.open(column_cache_file, 'w'))
  columns
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
