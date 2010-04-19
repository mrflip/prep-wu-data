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
  
  attr_accessor :title, :subtitle, :main_link, :description,
  :packages, :owner, :protected, :tags, :categories,
  :collection, :sources, :upload_files, :fields, :price,
  :records_count, :fmt, :snippet, :license, :score, :rating
  
  def initialize *args
    return unless args
    args.first.each {|key,value| instance_variable_set("@#{key}", value) }
  end

  def set_tags
    case tags
    when String
      @@dataset_arry.first['dataset']['tags'] = tags.gsub(/\,\s/,",").gsub(/\s/,"-").split(",")
    when Array
      @@dataset_arry.first['dataset']['tags'] = tags      
    end
  end

  def set_categories
    case categories
    when String
      @@dataset_arry.first['dataset']['categories'] = categories.gsub(/\,\s/,",").split(",")
    when Array
      @@dataset_arry.first['dataset']['categories'] = categories
    end
  end

  def set_sources
    case sources
    when String
      @@dataset_arry.first['dataset']['sources'] = sources.gsub(/\,\s/,",").split(",")
    when Array
      @@dataset_arry.first['dataset']['sources'] = sources
    when Hash
      @@dataset_arry.first['dataset']['sources'] = [sources]
    end
  end
  
  def set_upload_files
    case upload_files
    when String
      @@dataset_arry.first['dataset']['files_for_upload'] = upload_files.gsub(/\,\s/,",").split(",")
    when Array
      @@dataset_arry.first['dataset']['files_for_upload'] = upload_files
    end
  end

  def set_fields
    case fields
    when FieldYAML
      @@dataset_arry.first['dataset']['fields'] = fields.to_a
    when Array
      @@dataset_arry.first['dataset']['fields'] ||= []
      fields.each do |field|
        @@dataset_arry.first['dataset']['fields'] += field.to_a if field.is_a?(FieldYAML)
      end
    end
  end

  def set_snippet
    case snippet
    when SnippetYAML
      @@dataset_arry.first['dataset']['snippets'] = snippet.to_a
    when String
      @@dataset_arry.first['dataset']['snippets'] = [ {'columns' => nil, 'data' => snippet} ]
    end
  end

  def set_packages
    case packages
    when PackageYAML
      @@dataset_arry.first['dataset']['packages'] = packages.to_a
    when Array
      @@dataset_arry.first['dataset']['packages'] = []
      @packages.each do |package|
        @@dataset_arry.first['dataset']['packages'] += package.to_a if package.is_a?(PackageYAML)
      end
    end 
  end
  
  def missing_critical?
    return true if title.nil? or description.nil? or owner.nil?
    false
  end

  def missing_data_pointer?
    return true unless main_link or upload_files
    false
  end
  
  def to_a
    if missing_critical?
      warn "Warning: A dataset needs a title, description, and owner. This YAML file will not work with the bulk importer."
    end
    
    if missing_data_pointer?
      warn "Warning: A dataset needs either a main link or a package (files to upload). This YAML file will not work with the bulk importer."
    end
    
    @@dataset_arry = [ {'dataset' => {'title' => title, 'description' => description, 'owner' => owner, } } ]

    set_tags
    set_categories
    set_sources
    set_upload_files
    set_fields
    set_snippet
    set_packages

    @@dataset_arry.first['dataset']['subtitle'] = subtitle unless subtitle.nil?
    @@dataset_arry.first['dataset']['collection_title'] = collection unless collection.nil?  
    @@dataset_arry.first['dataset']['main_link'] = main_link unless main_link.nil?
    @@dataset_arry.first['dataset']['price'] = price unless price.nil?
    @@dataset_arry.first['dataset']['license_title'] = license unless license.nil?
    @@dataset_arry.first['dataset']['fmt'] = fmt unless fmt.nil?
    @@dataset_arry.first['dataset']['cached_score'] = score unless score.nil?
    @@dataset_arry.first['dataset']['rating'] = rating unless rating.nil?
    @@dataset_arry.first['dataset']['records_count'] = records_count unless records_count.nil?
    @@dataset_arry.first['dataset']['protected'] = protected unless protected.nil?
    @@dataset_arry    
  end
  
  def to_yaml
    @@dataset_yaml = self.to_a.to_yaml
  end    
end

#
# Each field is a little hash.  When put in an array it will make a nice list in the YAML file.
#

class FieldYAML
  
  attr_accessor :title, :description, :datatype, :unit

  def initialize *args
    return unless args
    args.first.each {|key,value| instance_variable_set("@#{key}", value) }
  end
  
  def to_a
    unless title
      warn "Warning: Each field needs a title."
      return
    end
    @@title_arry = [ {'title' => title} ]
    @@title_arry.first['description'] = description unless description
    @@title_arry.first['datatype'] = datatype unless datatype
    @@title_arry.first['unit'] = unit unless unit
    @@title_arry
  end
  
end

#
#
#

class SnippetYAML
  
  attr_accessor :columns, :data
  
  def initialize *args
    return unless args
    args.first.each {|key,value| instance_variable_set("@#{key}", value) }
  end
  
  def to_a
    @@snippet_arry = [ {'columns' => columns, 'data' => data} ]
    @@snippet_arry
  end
  
end


#
# Packages
#
class PackageYAML
  attr_accessor :kind, :path, :bucket, :fmt, :pkg_fmt, :pkg_size, :num_files, :records, :owner, :dataset, :upload_files
  
  def initialize *args
    return unless args
    args.first.each {|key,value| instance_variable_set("@#{key}", value) }
  end

  def missing_info?
    return true if (kind.nil? or path.nil? or bucket.nil? ) and (upload_files.nil? or dataset.nil? )
  end
  
  def to_a
    if missing_info?
      warn "A package needs either an S3 bucket or a list of files to upload."
    end
    if dataset.nil? and upload_files.nil?
      warn "Making a package from (hopefully) a S3 bucket."
      @@package_arry = [{}]
      @@package_arry.first['kind'] = kind unless kind
      @@package_arry.first['path'] = path unless path
      @@package_arry.first['bucket'] = bucket unless bucket
      @@package_arry.first['fmt'] = fmt unless fmt
      @@package_arry.first['pkg_fmt'] = pkg_fmt unless pkg_fmt
      @@package_arry.first['pkg_size'] = pkg_size unless pkg_size
      @@package_arry.first['num_files'] = num_files unless num_files
      @@package_arry.first['owner_id'] = owner unless owner
    else
      warn "Making a package from a list of files and a dataset."
      @@package_arry = {'dataset' => dataset}
      case upload_files
      when String
        @@package_arry.first['files_for_upload'] = upload_files.gsub(/\,\s/,",").split(",")
      when Array
        @@package_arry.first['files_for_upload'] = upload_files
      end
    end
    @@package_arry
  end
  
  def to_yaml
    @@package_yaml = [{'package' => self.to_a}]
    @@package_yaml.to_yaml
  end
end
