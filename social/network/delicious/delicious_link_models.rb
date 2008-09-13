# -*- coding: utf-8 -*-
require 'rubygems'
require 'dm-ar-finders'
require 'dm-aggregates'
require 'imw/dataset/datamapper'
require 'imw/dataset/datamapper/uri'

#DataMapper::Logger.new(STDOUT, :debug)
IMW::DataSet.setup_remote_connection IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_social_network_delicious' })


#
# Models for the delicious.com (formerly del.icio.us) social network
#
# Link:         has tags,   tagged by socialites
# Socialite:                describes links with tabs,  uses tags,         follows/followedby socialites
# Tag:          tags links,                             used by socialites

#
# First steps towards craws that can give an implied trust metric.
#   follow/follower graph
#   # follow/followers
#   # comments / posts / favorites / favorited
#   explicit karma
# sources:
#   Twitter
#   FriendFeed
#   Plurk (has explicit karma)
#   Twine
#   MetaFilter (also asked / answered numbers)
#   Ma.gnolia.com
#


class DeliciousLink
  include DataMapper::Resource
  # Basic info
  property      :id,                    Integer,  :serial => true
  property      :link_url,              String,   :length => 1024, :nullable => false
  property      :delicious_id,          String,   :length => 32,   :nullable => false,          :unique_index => true
  property      :num_delicious_savers,  Integer
  property      :title,                 String,   :length => 255
  has n,        :taggings
  has n,        :socialites_links
  has n,        :tags,          :through => :taggings
  has n,        :socialites,    :through => :socialites_links
end


