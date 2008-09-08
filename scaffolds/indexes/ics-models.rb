# -*- coding: utf-8 -*-
require 'rubygems'
require 'imw'; include IMW; IMW.verbose = true
require 'imw/dataset/datamapper'
require 'dm-ar-finders'
require 'dm-aggregates'
require 'dm-timestamps'
require 'slug'

#DataMapper::Logger.new(STDOUT, :debug)
DataSet.setup_remote_connection IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_ics_scaffold' })

#
# Datamapper interface to infochimps
#

class Dataset
  include DataMapper::Resource
  include Sluggable;
  slug_on :name
  property      :id,                            Integer,        :serial => true
  # property      :approved_at,                   DateTime
  # property      :approved_by,                   String,        :length      => 40
  property      :created_at,                    DateTime
  # property      :created_by,                    String,        :length      => 40
  property      :updated_at,                    DateTime
  # property      :updated_by,                    String,        :length      => 40
  #
  property      :name,                          String,        :length      => 255,         nil          => false, :default => ''
  property      :uniqname,                      String,        :length      => 40,         nil          => false
  property      :category,                      String,        :length      => 50,          nil          => false, :default => ''
  property      :url,                           String
  property      :collection_id,                 Integer
  property      :is_collection,                 Boolean,       :default     => false
  property      :valuation,                     String,        :default     => "{}"
  property      :num_downloads,                 Integer,       :default     => 0
  #
  has n,        :credits
  has n,        :contributors,                                :through     => :credits
  has n,        :notes
  has n,        :links
  has n,        :payloads
  has n,        :ratings
  has 1,        :rights_statement
  has 1,        :license,               :through => :rights_statement
  has n,        :taggings,                                      :child_key => [:taggable_id]
  has n,        :tags,                  :through => :taggings,  :child_key => [:taggable_id]

  def description=(text)
    desc = self.notes.find_or_create({ :role => 'description' })
    self.notes << desc
    desc.desc = text
  end
  # tags are ',' separated
  def tag_with(context, tags_list)
    tag_strs = tags_list.split(',').map{|s| s.gsub(/[^\w]+/,'') }.reject(&:blank?)
    tag_strs.each do |tag_str|
      tag     = Tag.find_or_create({ :name => tag_str })
      tagging = Tagging.find_or_create({ :tag_id => tag.id, :context => context, :taggable_id => self.id, :taggable_type => self.class.to_s })
    end if tag_strs
  end
  # adds a note with _context (hiding it from normal view)
  #
  def add_internal_note context, info
    note = internal_note context
    note.desc = info.to_yaml
    note.save
  end
  def internal_note context
    note = self.notes.find_or_create( :role => "_#{context}" )
    self.notes << note
    note
  end
  def register_info key, val
    info = YAML.load(internal_note(:info).desc) || {}
    (info[key]||=[]) << val
    info[key].uniq!
    add_internal_note :info, info.to_yaml
  end
  def credit contributor, attrs
    credit = Credit.find_or_create({ :dataset_id => self.id, :contributor_id => contributor.id, }, attrs)
  end


  before :save, :insert_default_rights_statement
  protected
  def insert_default_rights_statement
    if !self.rights_statement
      self.rights_statement = RightsStatement.create(:license => License.find_by_uniqname(:needs_rights))
    end
  end

end


class Contributor
  include DataMapper::Resource
  include Sluggable

  self.slug_on :url
  property      :id,                            Integer,        :serial => true
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  #
  property      :name,                          String,        :length      => 255
  property      :uniqname,                      String,        :length      => 40,         nil          => false
  property      :url,                           String,        :length      => 255
  property      :desc,                          Text
  property      :base_trustification,           Integer,        :default => 0
  has n,        :credits
  has n,        :datasets,                                    :through     => :credits
end

class Credit
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  property      :dataset_id,                    Integer
  property      :contributor_id,                Integer
  #
  property      :role,                          String,        :length      => 255,     nil          => false, :default => ''
  property      :citation,                      Text,                                   nil          => false, :default => ''
  property      :desc,                          Text,                                   nil          => false, :default => ''
  belongs_to    :dataset
  belongs_to    :contributor
end

class Tagging
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :created_at,                    DateTime
  property      :tag_id,                        Integer
  property      :taggable_id,                   Integer
  property      :taggable_type,                 String
  #
  property      :context,                       String
  belongs_to    :taggable, :class_name => 'Dataset', :child_key => [:taggable_id]
  belongs_to    :tag
end

class Tag
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :name,                          String
  has n,        :taggings
  # has n,        :taggables, :through => :taggings
end

class Link
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  property      :dataset_id,                   Integer
  property      :dataset_type,                 String
  before :save, :fake_polymorphism; def fake_polymorphism() self.dataset_type = 'Dataset' end
  #
  # property      :revhost,                       String,          nil          => false, :default => ''
  # property      :path,                          String,          nil          => false, :default => ''
  #
  property      :full_url,                      Text,            nil          => false, :default => ''
  property      :role,                          String,          nil          => false, :default => ''
  property      :name,                          String,        nil          => false, :default => ''
  property      :desc,                          String,          nil          => false, :default => ''
  belongs_to    :dataset,       :polymorphic  => true

  # Delegate methods to uri
  def uri
    @uri ||= Addressable::URI.heuristic_parse(self.full_url).normalize
  end
  # Dispatch anything else to the aggregated uri object
  def method_missing method, *args
    if self.uri.respond_to?(method)
      self.uri.send(method, *args)
    else
      super method, *args
    end
  end

end

class Note
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  property      :dataset_id,                   Integer
  property      :dataset_type,                 String
  before :save, :fake_polymorphism; def fake_polymorphism() self.dataset_type = 'Dataset' end
  #
  property      :role,                          String,        nil          => false, :default => ''
  property      :name,                          String,        nil          => false, :default => ''
  property      :desc,                          Text,          nil          => false, :default => ''
  belongs_to    :dataset,        :polymorphic  => true
end

class Rating
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  property      :user_id,                       Integer
  property      :dataset_id,                   Integer
  property      :dataset_type,                 String
  before :save, :fake_polymorphism; def fake_polymorphism() self.dataset_type = 'Dataset' end
  #
  property      :rating,                        Integer,       :default     => 0
  property      :context,                       String,        :default     => "overall"
  belongs_to    :dataset,                                    :polymorphic  => true
  belongs_to    :user
end

class RightsStatement
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :dataset_id,                    Integer
  property      :license_id,                    Integer
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  #
  property      :statement_url,                 String,        :length      => 255,          nil          => false, :default => ''
  property      :desc,                          Text,          nil          => false, :default => ''
  belongs_to    :license
  belongs_to    :dataset
end

class License
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  #
  property      :name,                          String,        nil          => false
  property      :uniqname,                      String,        :length      => 40,         nil          => false
  property      :desc,                          Text,          nil          => false, :default => ''
  property      :license_url,                   String,        :length      => 255
  has n,        :rights_statements
  has n,        :datasets,      :through => :rights_statements
end



class Payload
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  property      :dataset_id,                    Integer
  property      :uploaded_by,                   Integer
  #
  property      :file_name,                     String
  property      :file_path,                     String
  property      :format,                        String
  property      :shape,                         String
  property      :size,                          Integer
  property      :stats,                         Text
  property      :file_date,                     DateTime
  property      :signature,                     Text
  property      :signed_by,                     Integer
  property      :fingerprint,                   String
  belongs_to    :dataset
end

class Field
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  property      :dataset_id,                    Integer
  property      :table_id,                      Integer
  #
  property      :name,                          String
  property      :desc,                          Text
  property      :datatype,                      String
  property      :representation,                String
  property      :concepts,                      String
  property      :constraints,                   String
  property      :stats,                         Text
  belongs_to    :dataset
end

class User
  include DataMapper::Resource
  property      :id,                            Integer,        :serial => true
  property      :login,                         String,        nil          => false
  property      :name,                          String,        nil          => false
  property      :identity_url,                  String,        :unique      => true
  property      :email,                         String,        nil          => false
  property      :email_is_public,               Boolean,       :default     => false
  property      :created_at,                    DateTime
  property      :updated_at,                    DateTime
  property      :remember_token,                String,        :length       => 40
  property      :remember_token_expires_at,     DateTime
  property      :prefs,                         String,        :length      => 2048
  property      :info_edited_at,                DateTime
  property      :homepage_link,                 String,        :default     => ''
  property      :blurb,                         Text,          :default     => ''
  property      :public_key,                    Text
  property      :email_verification_code,       String,        :length       => 40
  property      :email_verified_at,             DateTime
  property      :roles,                         String,        :length      => 2048

end
