require 'dm-core'
require 'dm-types'
require 'configliere'
Settings.use :config_file, :define, :commandline
Settings.read 'open_data.yaml'
Settings.define :db_uri,  :description => "Base URI for database -- eg mysql://USERNAME:PASSWORD@localhost:9999", :required => true
Settings.define :db_name, :description => "Database name to use", :required => true
Settings.resolve!

DataMapper.setup(:default, Settings.db_uri+"/"+Settings.db_name)

class UkDataset
  include DataMapper::Resource
  
  property :id, Integer, :key => true
  property :title, Text
  property :url, Text
  property :author, String, :length => 255
  property :author_email, String, :length => 255
  property :maintainer, String, :length => 255
  property :maintainer_email, String, :length => 255
  property :license, String
  property :license_id, Integer
  property :tags, Text
  property :description, Text
  property :extras, Text
  property :revision_id, String, :key => true
  property :uploaded, DateTime
  
end