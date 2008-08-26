# -*- coding: utf-8 -*-
require 'rubygems'
require 'dm-ar-finders'
require 'dm-aggregates'

class User
  include DataMapper::Resource
  # Basic info
  property      :id,                         Integer,           :serial => true
  property      :twitter_name,               String,            :nullable => false, :unique_index => :twitter_name  # should be :unique_index
  property      :file_date,                  DateTime
  property      :twitter_id,                 Integer
  # Retrieval.  FIXME - should be in its own model
  property      :requested,                  Boolean,           :default => :null
  property      :scraped,                    Boolean,           :default => :null
  property      :parsed,                     Boolean,           :default => :null
  # Relations / Trust
  property      :following_count,            Integer
  property      :followers_count,            Integer
  property      :favorites_count,            Integer
  property      :updates_count,              Integer
  #
  property      :real_name,                  String,            :length => 255
  property      :location,                   String,            :length => 255
  property      :web,                        String,            :length => 255
  property      :bio,                        Text
  # Page appearance
  property      :style_profile_img_url,      Text
  property      :style_mini_img_url,         Text
  property      :style_bg_img_url,           Text
  property      :style_name_color,           Integer
  property      :style_link_color,           Integer
  property      :style_text_color,           Integer
  property      :style_bg_color,             Integer
  property      :style_sidebar_fill_color,   Integer
  property      :style_sidebar_border_color, Integer
  property      :style_bg_img_tile,          Boolean
  # Status info on page
  property      :last_seen_update_time,      DateTime
  property      :first_seen_update_time,     DateTime

  #
  # Associations
  #
  has n, :friendships,    :child_key => [:follower_id], :class_name => 'Friendship'
  has n, :followerships,  :child_key => [:friend_id],   :class_name => 'Friendship'
  has n, :statuses
  #
  # FIXME
  def followers() self.followerships.map{ |f| f.follower.twitter_name } end
  def friends()   self.friendships.map{   |f| f.friend.twitter_name   } end

  def seen_profile_page
    self.file_date
  end

  def self.ripd_file_dir chunk
    path_to :ripd, "profiles",  "twitter_id_#{chunk}"
  end
  def ripd_file_dir
    chunk = (twitter_name.length==1) ? twitter_name[0..0]+'_' : twitter_name[0..1]
    chunk.downcase!
    self.class.ripd_file_dir chunk
  end
  def ripd_file()
    File.join ripd_file_dir, twitter_name
  end
  def rip_url()
    "http://twitter.com/#{twitter_name}"
  end

  def self.users_with_profile chunk='*'
    Dir[ self.ripd_file_dir(chunk) ].sort.each do |dir|
      Dir[dir+'/*'].sort.each do |profile_page|
        user = User.find_or_create(:twitter_name => File.basename(profile_page))
        yield user
      end
    end
  end

  #
  # Playing with direct queries / hinting datamapper for
  # a bit better efficiency.
  #
  def self.all_by_chunks chunk_size, max_chunks=nil, &block
    chunk_size ||= 1e6.to_i
    n_chunks = [ (self.count/chunk_size).to_i, max_chunks ].compact.min
    (0 .. n_chunks).each do |chunk_i|
      chunk_limits = [chunk_i*chunk_size, (chunk_i+1)*chunk_size]
      announce "#{(chunk_limits.first/1000).to_i}k\t#{self.name.pluralize}"
      all_chunk chunk_limits, &block
    end
  end
  def self.all_chunk limits, conditions={ }
    conditions[:offset] ||= limits.min
    conditions[:limit]  ||= limits.max
    self.all(conditions).each do |u|
      yield u
    end
  end

end

#
# Following
#
class Friendship # < Fiddle
  include DataMapper::Resource
  property      :follower_id,   Integer,                :key => true
  property      :friend_id,     Integer,                :key => true, :index => :friend_id
  belongs_to    :follower,      :class_name => 'User',  :child_key => [:follower_id]
  belongs_to    :friend,        :class_name => 'User',  :child_key => [:friend_id]

  def self.all_by_chunks chunk_size, max_chunks=nil, &block
    chunk_size ||= 1e6.to_i
    n_chunks = [ (self.count/chunk_size).to_i, max_chunks ].compact.min
    (0 .. n_chunks).each do |chunk_i|
      chunk_limits = [chunk_i*chunk_size, (chunk_i+1)*chunk_size]
      announce "#{(chunk_limits.first/1000).to_i}k\t#{self.name.pluralize}"
      all_chunk chunk_limits, &block
    end
  end
  def self.all_chunk limits
    conditions = { :offset   => limits.min, :limit    => limits.max, }
    self.all(conditions).each do |u|
      yield u
    end
  end
end


#
# Status
#
class Status
  include DataMapper::Resource
  property      :id,                         Integer, :serial => true
  property      :twitter_id,                 Integer
  property      :datetime,                   DateTime # Text                       # FIXME
  property      :fromsource,                 String
  property      :fromsource_url,             String
  property      :inreplyto_name,             String, :length => 255
  property      :inreplyto_status_id,        Integer
  property      :content,                    Text
  property      :users_atsigned,             Text
  property      :hashtags,                   Text
  property      :content_urls,               Text
  # Associations
  belongs_to    :user
end

#
# class AtSign
#   include DataMapper::Resource
#   property      :posting_user
#   property      :status_id
#   property      :atsigned_user
#   belongs_to    :status
#   belongs_to    :user
#   belongs_to    :user
# end
#
# class HashTag
#   include DataMapper::Resource
#   property      :posting_user
#   property      :status_id
#   property      :hashtag
#   belongs_to    :status
#   belongs_to    :user
# end
#
# class Link
#   include DataMapper::Resource
#   property      :status_id
#   property      :url
#   belongs_to    :status
# end
#
