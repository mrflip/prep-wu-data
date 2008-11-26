# -*- coding: utf-8 -*-
require 'rubygems'
require 'dm-ar-finders'
require 'dm-aggregates'

class TwitterUser
  include DataMapper::Resource
  # Basic info
  property :id,                         Integer, :serial   => true
  property :twitter_name,               String,  :nullable => false, :unique_index => :twitter_name
  property :native_id,                  Integer
  property :last_scraped_date,          DateTime
  # Relations
  property :following_count,            Integer
  property :followers_count,            Integer
  property :favorites_count,            Integer
  # Identity
  property :real_name,                  String,  :length   => 255
  property :location,                   String,  :length   => 255
  property :web,                        String,  :length   => 255
  property :bio,                        Text
  # Page appearance
  property :profile_img_url,            Text
  property :mini_img_url,               Text
  property :bg_img_url,                 Text
  property :style_name_color,           Integer
  property :style_link_color,           Integer
  property :style_text_color,           Integer
  property :style_bg_color,             Integer
  property :style_sidebar_fill_color,   Integer
  property :style_sidebar_border_color, Integer
  property :style_bg_img_tile,          Boolean
  # Tweet info on page
  property :updates_count,              Integer
  property :last_seen_update_time,      DateTime
  property :first_seen_update_time,     DateTime

  property :parsed,                     Boolean
  property :failed,                     Boolean
  #
  # Associations
  #
  has n, :friendships,    :child_key => [:follower_id], :class_name => 'Friendship'
  has n, :followerships,  :child_key => [:friend_id],   :class_name => 'Friendship'
  has n, :tweets
  #
  # FIXME
  def follower_names() self.followerships.map{ |f| f.follower.twitter_name } end
  def friend_names()   self.friendships.map{   |f| f.friend.twitter_name   } end
end

#
# Following
#
class Friendship # < Fiddle
  include DataMapper::Resource
  property   :follower_id, Integer, :key => true
  property   :friend_id,   Integer, :key => true, :index => :friend_id
  belongs_to :follower, :class_name => 'TwitterUser', :child_key => [:follower_id]
  belongs_to :friend,   :class_name => 'TwitterUser', :child_key => [:friend_id]
end

#
# Prestige Analysis
#
class TwitterPageRank
  include DataMapper::Resource
  property      :prestige,        Integer, :index => :user_prestige
  property      :twitter_user_id, Integer, :key   => true, :index => :user_prestige
  property      :page_rank,       Float
end

#
# Tweet
#
class Tweet
  include DataMapper::Resource
  property   :id,                 Integer, :serial => true
  property   :twitter_user_id,    Integer
  property   :datetime,           DateTime
  property   :fromsource,         String
  property   :fromsource_url,     String
  property   :inreplyto_name,     String,  :length => 255
  property   :inreplyto_tweet_id, Integer
  property   :content,            Text
  property   :all_atsigns,        Text
  property   :all_hash_tags,      Text
  property   :all_tweeted_urls,   Text
  # Associations
  belongs_to :twitter_user
  # has n,     :at_signs
  # has n,     :tweet_hash_tags
  # has n,     :tweet_tweeted_urls
end

# #
# # Tweet Connections
# #
# class AtSign
#   include DataMapper::Resource
#   property      :id,           Integer, :serial => true
#   property      :from_user_id, Integer, :index  => [:from_to]
#   property      :to_user_id,   Integer, :index  => [true, :from_to]
#   property      :tweet_id,    Integer
#   belongs_to    :tweet
#   belongs_to    :from_user, :class_name => 'TwitterUser', :child_key => [:from_user_id]
#   belongs_to    :to_user,   :class_name => 'TwitterUser', :child_key => [:to_user_id]
# end
#
# class HashTag
#   property      :id,            Integer, :serial => true
#   property      :name,          String,  :length => 255
#   has n,        :tweet_hash_tags
# end
#
# class TweetedUrl
#   property      :id,            Integer, :serial => true
#   property      :url,           String,  :length => 255
#   property      :expanded_url,  Text
#   has n,        :tweet_tweeted_urls
# end
#
# class TweetHashTag
#   include DataMapper::Resource
#   property      :id,            Integer, :serial => true
#   property      :from_user_id,  Integer, :index  => [:from_to]
#   property      :hashtag_id,    Integer, :index  => [true, :from_to]
#   property      :tweet_id,     Integer
#   belongs_to    :tweet
#   belongs_to    :from_user,  :class_name => 'TwitterUser', :child_key => [:from_user_id]
#   belongs_to    :hashtag
# end
#
# class TweetTweetedUrl
#   include DataMapper::Resource
#   property   :id,              Integer, :serial => true
#   property   :from_user_id,    Integer, :index  => [:from_to]
#   property   :tweeted_url_id,  Integer, :index  => [true, :from_to]
#   property   :tweet_id,       Integer
#   belongs_to :tweet
#   belongs_to :from_user,     :class_name => 'TwitterUser', :child_key => [:from_user_id]
#   belongs_to :tweeted_url
# end

# class Retrieval
#   include DataMapper::Resource
#   # Retrieval.  FIXME - should be in its own model
#   # property      :file_date, DateTime
#   # property      :requested, Boolean, :default => :null
#   # property      :scraped,   Boolean, :default => :null
#   # property      :parsed,    Boolean, :default => :null
#   def seen_profile_page
#     self.file_date
#   end
#   def self.ripd_file_dir chunk
#     path_to :ripd, "profiles",  "twitter_id_#{chunk}"
#   end
#   def ripd_file_dir
#     chunk = (twitter_name.length==1) ? twitter_name[0..0]+'_' : twitter_name[0..1]
#     chunk.downcase!
#     self.class.ripd_file_dir chunk
#   end
#   def ripd_file()
#     File.join ripd_file_dir, twitter_name
#   end
#   def rip_url()
#     "http://twitter.com/#{twitter_name}"
#   end
#   def self.users_with_profile chunk='*'
#     Dir[ self.ripd_file_dir(chunk) ].sort.each do |dir|
#       Dir[dir+'/*'].sort.each do |profile_page|
#         user = TwitterUser.find_or_create(:twitter_name => File.basename(profile_page))
#         yield user
#       end
#     end
#   end
#   #
#   # Playing with direct queries / hinting datamapper for
#   # a bit better efficiency.
#   #
#   def self.all_by_chunks chunk_size, max_chunks=nil, &block
#     chunk_size ||= 1e6.to_i
#     n_chunks = [ (self.count/chunk_size).to_i, max_chunks ].compact.min
#     (0 .. n_chunks).each do |chunk_i|
#       chunk_limits = [chunk_i*chunk_size, (chunk_i+1)*chunk_size]
#       announce "#{(chunk_limits.first/1000).to_i}k\t#{self.name.pluralize}"
#       all_chunk chunk_limits, &block
#     end
#   end
#   def self.all_chunk limits, conditions={ }
#     conditions[:offset] ||= limits.min
#     conditions[:limit]  ||= limits.max
#     self.all(conditions).each do |u|
#       yield u
#     end
#   end
# end
