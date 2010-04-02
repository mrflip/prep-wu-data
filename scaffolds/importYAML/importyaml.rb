require 'rubygems'
require 'yaml'

# USAGE:
#
# dataset = DatasetYAML.new(:title => "Awesome Dataset", :owner => "Me!", :description => "This is my dataset.")
#
# -- or --
#
# dataset = DatasetYAML.new
# dataset.title = "Awesome Dataset"
# dataset.description = "This is a description of my dataset."
# dataset.owner = "Me!"
# dataset.protected = "true"
# dataset.tags = ["tag1","tag2", "tag3"]
# dataset.sources = ["Title of source1", "Title of source2", "Title of source3"]
# dataset.sources = Hash.new{ :title => "Title of new source", :description => "Description of source", :main_link => "Link to source" }
# dataset.upload_files = ["path/to/file1", "path/to/file2"]
# dataset.fields = [FieldYAML.new( :title => "title1" ), FieldYAML.new( :title => "title2" )]
# dataset.price = 0.00
# dataset.score = 10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 
#


# Various items have the following contraints built into the site:
# (perhaps these validations should be added into the to_yaml def at some point)
#
# MAX_TITLE_LEN      = 100
# MAX_USERNAME_LEN   =  25
# MAX_TAG_NAME_LEN   =  25
# MAX_FORMAT_LEN     =  20
# MAX_SUBCAT_LEN     =  20
# MAX_MODEL_NAME_LEN =  20
# MAX_PATH_LEN       = 255
# MAX_URL_LEN        = 255
# MAX_SUBTITLE_LEN   = 255
# MAX_SLUG_LEN       =  64
# MAX_HANDLE_LEN     = MAX_SLUG_LEN + 6
# MAX_QUERY_LEN      = 255
# MAX_EMAIL_LEN      = MAX_URL_LEN
# MAX_UUID_LEN       = 60
# MAX_SHA1_LEN       = 40
# MAX_IPADDR_LEN     = 15
# MAX_SHORT_NOTE_LEN = 255
#
# title must not have non printing characters (ie must be on one line)
# URL should also not contain the following: ", [, ], !, ip address (replace with `host IP`)


#
# Each dataset is a hash in an array.  Multiple DatasetYAML.to_a can be added together to put multiple listings in one file.
#  

class DatasetYAML
  
  attr_accessor :title, 
  :subtitle,
  :main_link, 
  :description,
  :packages, 
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
      warn "A dataset needs a title, description, and owner. This YAML file will not work with the bulk importer."
    end
    if !(@main_link || @upload_files)
      warn "A dataset needs either a main link or a package (files to upload). This YAML file will not work with the bulk importer."
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
    if @snippet.is_a?(String)
      @@dataset_arry[0]['dataset']['snippets'] = [{'columns'=>nil, 'data'=>@snippet.to_s}]
    end
    if @packages.is_a?(PackageYAML)
      @@dataset_arry[0]['dataset']['packages'] = @packages.to_a
    end
    if @packages.is_a?(Array)
      @@dataset_arry[0]['dataset']['packages'] = []
      @packages.each do |package|
        @@dataset_arry[0]['dataset']['packages'] += package.to_a if package.is_a?(PackageYAML)
      end
    end 
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
# Packages
#
class PackageYAML
  attr_accessor :kind,
  :path,
  :bucket,
  :fmt,
  :pkg_fmt,
  :pkg_size,
  :files,
  :records,
  :owner,
  :dataset,
  :upload_files
  
  def initialize *args
    return if args.empty?
    args[0].each {|key,value| instance_variable_set("@#{key}", value) }
  end
  
  def to_a
    if (@kind == nil || @path == nil || @bucket == nil) && (@upload_files == nil || @dataset == nil)
      warn "A package needs either an S3 bucket or a list of files to upload."
    end
    if @dataset == nil && @upload_files == nil
      warn "Making a package from (hopefully) a S3 bucket."
      @@package_arry = [{}]
      @@package_arry[0]['kind'] = @kind if @kind != nil
      @@package_arry[0]['path'] = @path if @path != nil
      @@package_arry[0]['bucket'] = @bucket if @bucket != nil
      @@package_arry[0]['fmt'] = @fmt if @fmt != nil
      @@package_arry[0]['pkg_fmt'] = @pkg_fmt if @pkg_fmt != nil
      @@package_arry[0]['pkg_size'] = @pkg_size if @pkg_size != nil
      @@package_arry[0]['num_files'] = @num_files if @num_files != nil
      @@package_arry[0]['owner_id'] = @owner if @owner != nil
    else
      warn "Making a package from a list of files and a dataset."
      @@package_arry = {'dataset' => @dataset}
      if @upload_files.is_a?(String)
        @@package_arry[0]['files_for_upload'] = @upload_files.gsub(/\,\s/,",").split(",")
      end
      if @upload_files.is_a?(Array)
        @@package_arry[0]['files_for_upload'] = @upload_files
      end
    end
    @@package_arry
  end
  
  def to_yaml
    @@package_yaml = [{'package'=>self.to_a}]
    @@package_yaml.to_yaml
  end
  
end
