#!/usr/bin/env ruby
require 'cassandra'

module CassandraUserIDCache
  # so there actually needs to be three separate keyspace columns
  # screen_name => (user_id_triplet)
  # user_id     => (user_id_triplet)
  # search_id   => (user_id_triplet)
  # where (user_id_triplet) is a hash containing all three screen_name, user_id, and search_name

  def has_api_id? api_id
    not key_cache.get('UserID', api_id).blank?
  end

  def has_search_id? search_id
    not key_cache.get('UserSearchID', api_id).blank?
  end

  def has_screen_name? screen_name
    not key_cache.get('UserScreenName', api_id).blank?
  end

  def insert_search_id search_id, user_id_triplet
    key_cache.insert('UserSearchID', search_id, user_id_triplet)
  end

  def insert_api_id api_id, user_id_triplet
    key_cache.insert('UserID', api_id, user_id_triplet)
  end

  def insert_screen_name screen_name, user_id_triplet
    key_cache.insert('UserScreenName', screen_name, user_id_triplet)
  end

  def get_user_id_triplet key, column_space
    key_cache.get(column_space, key)
  end

  def key_cache
    @key_cache ||= Cassandra.new('UserIDCache')
  end

end
