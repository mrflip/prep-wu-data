# -*- coding: utf-8 -*-
require 'rubygems'
require 'dm-ar-finders'
require 'dm-aggregates'

class TwitterUser
  include DataMapper::Resource
  # Basic info
  property :id,                         Integer, :serial   => true
  property :screen_name,                String,  :length =>  50, :nullable => false, :unique_index => :twitter_name
  property :created_at,                 DateTime
  # Counts
  property :statuses_count,             Integer
  property :followers_count,            Integer
  property :friends_count,              Integer
  property :favourites_count,           Integer # note spelling
  property :protected,                  Boolean
  property :scraped_at,                 DateTime
  #
  # Associations
  #
  has 1, :twitter_user_profile
  has 1, :twitter_user_style
  has 1, :twitter_user_metric
  has n, :a_follows_bs,   :child_key => [:user_a_id], :class_name => 'AFollowsB'
  has n, :b_follows_as,   :child_key => [:user_b_id], :class_name => 'AFollowsB'
  # has n, :a_symmetric_bs, :child_key => [:user_a_id], :class_name => 'ASymmetricB'
  # has n, :b_symmetric_as, :child_key => [:user_b_id], :class_name => 'ASymmetricB'
  has n, :a_replied_bs,   :child_key => [:user_a_id], :class_name => 'ARepliedB'
  has n, :b_replied_as,   :child_key => [:user_b_id], :class_name => 'ARepliedB'
  has n, :a_atsigns_bs,   :child_key => [:user_a_id], :class_name => 'AAtsignsB'
  has n, :b_atsigns_as,   :child_key => [:user_b_id], :class_name => 'AAtsignsB'
  has n, :tweet_urls,     :child_key => [:user_a_id], :class_name => 'TweetUrl'
  has n, :hashtags,       :child_key => [:user_a_id], :class_name => 'Hashtag'
  has n, :tweets
end

class TwitterUserProfile
  include DataMapper::Resource
  property :twitter_user_id,            Integer, :key => true
  # Identity
  property :name,                       String,  :length   => 255
  property :url,                        String,  :length   => 255
  property :location,                   String,  :length   => 255
  property :description,                Text
  property :time_zone,                  String,  :length   => 255
  property :utc_offset,                 Integer
  property :scraped_at,                 DateTime
  belongs_to :twitter_user
end

class TwitterUserStyle
  include DataMapper::Resource
  property :twitter_user_id,            Integer, :key => true
  property :profile_background_color,     String,  :length   => 6
  property :profile_text_color,           String,  :length   => 6
  property :profile_link_color,           String,  :length   => 6
  property :profile_sidebar_border_color, String,  :length   => 6
  property :profile_sidebar_fill_color,   String,  :length   => 6
  property :profile_background_image_url, String,  :length   => 255
  property :profile_image_url,            String,  :length   => 255
  property :profile_background_tile,      Boolean
  property :scraped_at,                   DateTime
  belongs_to :twitter_user
end

# #
# # Post-analysis User Metrics
# #
# class TwitterUserMetrics
#   include DataMapper::Resource
#   property      :prestige,        Integer, :index => :user_prestige
#   property      :twitter_user_id, Integer, :key   => true, :index => :user_prestige
#   property      :page_rank,       Float
#   belongs_to    :twitter_user
# end

#
# Following
#
class AFollowsB
  include DataMapper::Resource
  property   :user_a_id,                Integer, :key => true,    :index => :user_ids
  property   :user_b_id,                Integer, :key => true,    :index => [:user_ids,   :user_b_id]
  property   :user_a_name,              String,  :length   => 50, :index => :names
  property   :user_b_name,              String,  :length   => 50, :index => [:user_names, :user_b_name]
  property   :scraped_at,               DateTime
  belongs_to :user_a, :class_name => 'TwitterUser', :child_key => [:user_a_id]
  belongs_to :user_b, :class_name => 'TwitterUser', :child_key => [:user_b_id]
end

#
# Replied
#
class AFollowsB
  include DataMapper::Resource
  property   :user_a_id,                Integer, :key => true,    :index => :user_ids
  property   :user_b_id,                Integer, :key => true,    :index => [:user_ids,   :user_b_id]
  property   :status_id,                Integer
  property   :in_reply_to_status_id,    Integer
  property   :scraped_at,               DateTime
  belongs_to :user_a, :class_name => 'TwitterUser', :child_key => [:user_a_id]
  belongs_to :user_b, :class_name => 'TwitterUser', :child_key => [:user_b_id]
end
#
# @atsign
#
class AAtsignsB
  include DataMapper::Resource
  property   :user_a_id,                Integer, :key => true,    :index => :user_ids
  property   :user_b_id,                Integer, :key => true,    :index => [:user_ids,   :user_b_id]
  property   :user_a_name,              String,  :length   => 50, :index => :names
  property   :user_b_name,              String,  :length   => 50, :index => [:user_names, :user_b_name]
  property   :status_id,                Integer
  property   :scraped_at,               DateTime
  belongs_to :user_a, :class_name => 'TwitterUser', :child_key => [:user_a_id]
  belongs_to :user_b, :class_name => 'TwitterUser', :child_key => [:user_b_id]
end

class TweetHashtag
  include DataMapper::Resource
  property      :user_a_id,             Integer, :key    => true
  property      :hashtag,               String,  :key    => true, :length => 140
  property      :status_id,             Integer, :key    => true
  property      :scraped_at,            DateTime
  belongs_to    :user_a,     :class_name => 'TwitterUser', :child_key => [:user_a_id]
  belongs_to    :tweet,      :class_name => 'Tweet',       :child_key => [:status_id]
end

class TweetUrl
  include DataMapper::Resource
  property      :user_a_id,             Integer, :key    => true
  property      :tweet_url,             String,  :key    => true, :length => 140
  property      :status_id,             Integer, :key    => true
  property      :scraped_at,            DateTime
  belongs_to    :user_a,     :class_name => 'TwitterUser', :child_key => [:user_a_id]
  belongs_to    :tweet,      :class_name => 'Tweet',       :child_key => [:status_id]
end

class ExpandedUrl
  include DataMapper::Resource
  property      :short_url,             String,  :key    => true, :length => 60
  property      :dest_url,              String,                   :length => 1024
  property      :scraped_at,            DateTime
end

#
# Tweet
#
class Tweet
  include DataMapper::Resource
  property   :id,                    Integer, :key => true
  property   :created_at,            DateTime
  property   :twitter_user_id,       Integer
  property   :text,                  String,  :length => 160
  property   :favorited,             Boolean
  property   :truncated,             Boolean
  property   :tweet_len,             Integer
  property   :in_reply_to_user_id,   Integer
  property   :in_reply_to_status_id, Integer
  property   :fromsource,            String, :length => 255
  property   :fromsource_url,        String, :length => 255
  property   :all_atsigns,           Text
  property   :all_hashtags,          Text
  property   :all_tweet_urls,        Text
  property   :scraped_at,            DateTime
  # Associations
  belongs_to :twitter_user
  has n,     :a_replied_b,                                     :child_key => [:status_id]
  has n,     :in_reply_tos,        :class_name => 'ARepliedB', :child_key => [:in_reply_to_status_id]
  has n,     :a_atsigns_b,                                     :child_key => [:status_id]
  has n,     :tweet_urls,                                      :child_key => [:status_id]
  has n,     :hashtags,                                        :child_key => [:status_id]
end

# class TwitterScrapeRequest
#   include ScrapeRequest
#   # connect to twitter model
#   property   :twitter_user_id,  Integer
#   property   :screen_name,      String,  :index => [:screen_name]
#   property   :page,             Integer
#   belongs_to :twitter_user
#   #
# end


require 'imw/chunk_store/scrape'
class TwitterScrapeFile
  include ScrapeFile
  attr_accessor :screen_name, :context, :page
  #
  # Create from a screen_name, context and page number
  #
  def initialize screen_name, context, page
    self.screen_name = screen_name
    self.context    = context
    self.page       = page
  end
  RESOURCE_PATH_FROM_CONTEXT = {
    :followers => 'statuses/followers', :friends => 'statuses/friends', :user => 'users/show'}
  def resource_path
    RESOURCE_PATH_FROM_CONTEXT[context]
  end
  # Fake the cached_uri path
  def ripd_file
    base_path = "_com/_tw/com.twitter/#{resource_path}"
    prefix    = (screen_name+'.')[0..1]
    slug_path = "_" + prefix.downcase
    filename  = "#{screen_name}.json%3Fpage%3D#{page}"
    path_to(:ripd_root, base_path, slug_path, filename) # :ripd_root
  end
  #
  def rip_uri
    "http://twitter.com/#{resource_path}/#{screen_name}.json?page=#{page}"
  end


  RIPD_FILE_RE = %r{_com/_tw/com.twitter/(\w+/\w+)/_\w[\w\.]/(\w+)\.json%3Fpage%3D(\d+)}
  def self.new_from_ripd_file filename
    m = RIPD_FILE_RE.match(filename)
    unless m then warn "Can't grok filename #{filename}"; return nil; end
    resource, screen_name, page = m.captures
    context = RESOURCE_PATH_FROM_CONTEXT.invert[resource]
    scrape_file = self.new screen_name, context, page
    scrape_file
  end

end


