require 'dm-core'
require 'dm-types'
require 'configliere'
Settings.use :config_file, :define, :commandline
Settings.read 'open_data.yaml'
Settings.define :db_uri,  :description => "Base URI for database -- eg mysql://USERNAME:PASSWORD@localhost:9999", :required => true
Settings.define :db_name, :description => "Database name to use", :required => true
Settings.resolve!

DataMapper.setup(:default, Settings.db_uri+"/"+Settings.db_name)

class SanfranDataset
  include DataMapper::Resource
  
  property :id, Serial
  property :title, String, :length => 255
  property :url, String, :length => 255
  property :tags, Text
  property :description, Text
  property :extras, Text
  property :uploaded, DateTime
  
end