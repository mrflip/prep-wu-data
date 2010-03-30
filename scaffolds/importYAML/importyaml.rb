require 'rubygems'
require 'yaml'

# - dataset:
#     title: The title of this dataset
#     subtitle: The subtitle of this dataset
#     main_link: http://www.google.com
#     protected: false
#     description: >-
# 
#       This is my dataset
# 
#     # can be either strings or numeric IDs
#     owner: Infochimps
# 
#     # can be either a string giving an existing collection's title,
#     # handle, or ID or a hash giving a new collection's attributes
#     collection: My Awesome Datasets
#     # or (but not both)
#     collection:
#       title: My Awesome Datasets
#       description: They are really cool
#
#     # tags are always referred to by name, never ID
#     tags:
#       - money
#       - finance
#       - stocks
# 
#     # categories can be referred to by path or ID    
#     categories:
#       - "Social Sciences::Education"
#       - 82
# 
#     # existing sources can be referred to by title or ID if they
#     # already exist
#     sources:
#       - The first source
#       - 1938
#       - The third source
#       # but you can also create a source inline by using a hash with
#       # attributes
#       - title: A new source
#         description: What this new source is like
#         main_link: http://foobar.com
#
#     # payloads can be created as nested subresources
#     payloads:
#       - title: A payload
#       # ... and so on, check the required YAML for payloads to learn
#       # more


# Any payload hash with a key "files_to_upload" will cause the importer
# to output a YAML file consisting of new payload IDs mapped to the list
# of files to upload.  This YAML file can subsequently be fed to the
# bulk upload script.
# 
# - payload:
#     title: The name of this payload
#     fmt: csv
#     price: 10000
#     protected: true
# 
#     # the following can be either strings or numeric IDs
#     dataset: Some Infochimps Dataset
#     owner: Infochimps
# 
#     # An existing license can be referred to by name and a new license
#     # an be created inline by using a hash
#     license: MIT License
#     # or (but not both)
#     license:
#       title: My New License
#       main_link: http://foobar.com
#       description: Whatever dude
#
#     schema_fields:
#       - handle: AvgLength
#         unit:  km
#         datatype: float
#
#         # can be either a string or the numeric ID of a schema_field
#         title: Average Length
#
#         description: >-
#           Average length measurements are defined over...
#
#     snippets:
#       - columns:
#         - FirstField
#         - SecondField
#         data:
#         # give each row of data on its own line
#         - [1,2,3]
#         - ['a', 'b', 'c']
#         - # or split each row and have each entry on a line
#           - 1
#           - 2
#           - 3
#       - columns: ["Another Field", "Yet Another Field"]
#         data: [[1,2,3],[4,5,6],[7,8,9]]
#
#     # list of local paths (relative to this YAML file) to upload.
#     # will be incorporated into an output YAML file suitable for the
#     # bulk uploader.
#     files_for_upload:
#       - relative/path/to/data
#       - /absolute/path/to/data
#       - ../another/relative/path/to/data

# - source:
#     title: The title of this source
#     main_link: "http://www.google.com"
#     description: >-
#
#       This is some description

# - collection:
#     title: The title of this collection
#     description: >-
#
#       This is some description

#
# Each field is a little hash.  When put in an array it will make a nice list in the YAML file.
#

class FieldYAML
  
  attr_accessor :title,
                :description,
                :datatype,
                :unit

  def initialize *args
    return if args.empty?
    args[0].each {|key,value| instance_variable_set("@#{key}", value) }
  end
  
  def to_a
    if @title == nil
      warn "Each field needs a title."
      return
    end
    @@title_arry = [{'title'=>@title}]
    @@title_arry[0]['description'] = @description if @description != nil
    @@title_arry[0]['datatype'] = @datatype if @datatype != nil
    @@title_arry[0]['unit'] = @unit if @unit != nil
    @@title_arry
  end
  
end

#
#
#

class SnippetYAML
  
  attr_accessor :columns,
                :data
                
  def initialize *args
    return if args.empty?
    args[0].each {|key,value| instance_variable_set("@#{key}", value) }
  end
  
  def to_a
    @@snippet_arry = [{'columns'=>@columns, 'data'=>@data}]
    @@snippet_arry
  end
  
end
                
#
# Each dataset is a hash in an array.  Multiple DatasetYAML.to_a can be added together to put multiple listings in one file.
#  

class DatasetYAML
  
  attr_accessor :title, 
                :subtitle,
                :main_link, 
                :description, 
                :owner,
                :protected,
                :tags, 
                :categories,
                :collection, 
                :sources,
                :upload_files,
                :fields,
                :price,
                :records_count,
                :fmt,
                :snippet,
                :license,
                :score,
                :rating
  
  def initialize *args
    return if args.empty?
    args[0].each {|key,value| instance_variable_set("@#{key}", value) }
  end
  
  def to_a
    if @title == nil || @description == nil || @owner == nil
      warn "A dataset needs a title, description, and owner."
      return
    end
    if !(@main_link || @upload_files)
      warn "A dataset needs either a main link or a payload (files to upload)."
      return
    end
    @@dataset_arry = [{'dataset'=>{
      'title'=>@title,
      'description'=>@description,
      'owner'=>@owner,
      }}]
    if @tags.is_a?(String)
      @@dataset_arry[0]['dataset']['tags'] = @tags.gsub(/\,\s/,",").gsub(/\s/,"-").split(",")
    end
    if @tags.is_a?(Array)
      @@dataset_arry[0]['dataset']['tags'] = @tags
    end
    if @categories.is_a?(String)
      @@dataset_arry[0]['dataset']['categories'] = @categories.gsub(/\,\s/,",").split(",")
    end
    if @categories.is_a?(Array)
      @@dataset_arry[0]['dataset']['categories'] = @categories
    end
    if @sources.is_a?(String)
      @@dataset_arry[0]['dataset']['sources'] = @sources.gsub(/\,\s/,",").split(",")
    end
    if @sources.is_a?(Array)
      @@dataset_arry[0]['dataset']['sources'] = @sources
    end
    if @sources.is_a?(Hash)
      @@dataset_arry[0]['dataset']['sources'] = [@sources]
    end
    if @upload_files.is_a?(String)
      @@dataset_arry[0]['dataset']['files_for_upload'] = @upload_files.gsub(/\,\s/,",").split(",")
    end
    if @upload_files.is_a?(Array)
      @@dataset_arry[0]['dataset']['files_for_upload'] = @upload_files
    end
    if @fields.is_a?(FieldYAML)
      @@dataset_arry[0]['dataset']['fields'] = @fields.to_a
    end
    if @fields.is_a?(Array)
      @@dataset_arry[0]['dataset']['fields'] = []
      @fields.each do |field|
        @@dataset_arry[0]['dataset']['fields'] += field.to_a if field.is_a?(FieldYAML)
      end
    end
    if @snippet.is_a?(SnippetYAML)
      @@dataset_arry[0]['dataset']['snippets'] = @snippet.to_a
    end
#
# Payloads are outdated now with the early March 2010 site update
#
#    if @payloads.is_a?(PayloadYAML)
#      @@dataset_arry[0]['dataset']['payloads'] = @payloads.to_a
#    end
#    if @payloads.is_a?(Array)
#      @@dataset_arry[0]['dataset']['payloads'] = []
#      @payloads.each do |payload|
#        @@dataset_arry[0]['dataset']['payloads'] += payload.to_a if payload.is_a?(PayloadYAML)
#      end
#    end 
    @@dataset_arry[0]['dataset']['subtitle'] = @subtitle if @subtitle != nil
    @@dataset_arry[0]['dataset']['collection_title'] = @collection if @collection != nil  
    @@dataset_arry[0]['dataset']['main_link'] = @main_link if @main_link != nil 
    @@dataset_arry[0]['dataset']['price'] = @price if @price != nil
    @@dataset_arry[0]['dataset']['license_title'] = @license if @license != nil
    @@dataset_arry[0]['dataset']['fmt'] = @fmt if @fmt != nil
    @@dataset_arry[0]['dataset']['cached_score'] = @score if @score != nil
    @@dataset_arry[0]['dataset']['rating'] = @rating if @rating != nil
    @@dataset_arry[0]['dataset']['records_count'] = @records_count if @records_count != nil
    @@dataset_arry[0]['dataset']['protected'] = @protected if @protected != nil  
    @@dataset_arry    
  end
  
  def to_yaml
    @@dataset_yaml = self.to_a
    @@dataset_yaml.to_yaml
  end    
  
end

#
# Payloads are outdated now with the early March 2010 site update
#
class PayloadYAML
  attr_accessor :title,
                :description,
                :fmt,
                :price,
                :owner,
                :protected,
                :license,
                :records_count,
                :upload_files,
                :fields
                
  def initialize *args
    return if args.empty?
    args[0].each {|key,value| instance_variable_set("@#{key}", value) }
  end
  
  def to_a
    if @title == nil || @description == nil || @fmt == nil || @license == nil || @owner == nil
      warn "A payload needs a title, description, owner, format, and license."
      return
    end
    @@payload_arry = [{'title'=>@title,
      'description'=>@description,
      'fmt'=>@fmt,
      'owner'=>@owner,
      'license'=>@license}]
    if @upload_files.is_a?(String)
      @@payload_arry[0]['files_for_upload'] = @upload_files.gsub(/\,\s/,",").split(",")
    end
    if @upload_files.is_a?(Array)
      @@payload_arry[0]['files_for_upload'] = @upload_files
    end
    @@payload_arry[0]['protected'] = @protected if @protected != nil
    @@payload_arry[0]['records_count'] = @records_count if @records_count != nil
    @@payload_arry[0]['price'] = @price if @price != nil
    @@payload_arry[0]['schema_fields'] = @fields if @fields != nil
    @@payload_arry
  end
  
  def to_yaml
    @@payload_yaml = [{'payloads'=>self.to_a}]
    return unless @@payload_yaml[0]['payloads'] != nil
    @@payload_yaml.to_yaml
  end
  
end
