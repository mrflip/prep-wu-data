#!/usr/bin/env ruby
require 'cassandra'
CASSANDRA_KEYSPACE = 'UserIDCache'

module CassandraUserIDCache



  # so there actually needs to be three separate keyspace columns
  # screen_name => (triplet)
  # user_id     => (triplet)
  # search_id   => (triplet)
  # where (triplet) is a hash containing all three screen_name, user_id, and search_name


  def has_key? key
    not key_cache.get(conditional_output_key_column, key).blank?
  end

  # register key in the key_cache
  def set_key key, data
    key_cache.insert(conditional_output_key_column, key, data)
  end

  # nuke key from the key_cache
  def remove_key key
    key_cache.remove(conditional_output_key_column, key)
  end

  def insert_search_id search_id, triplet
    key_cache.insert('UserSearchID', search_id, triplet)
  end

  def insert_api_id api_id, triplet
    key_cache.insert('UserID', api_id, triplet)
  end

  def insert_screen_name screen_name, triplet
    key_cache.insert('UserScreenName', screen_name, triplet)
  end
  # The cache
  def key_cache
    @key_cache ||= Cassandra.new(CASSANDRA_KEYSPACE)
  end

  # The column to use for the key cache. By default, the class name plus 'Keys',
  # but feel free to override.
  #
  # @example
  #
  #    class FooMapper < Wukong::Streamer::RecordStreamer
  #      include ConditionalOutputter
  #    end
  #    FooMapper.new.conditional_output_key_column
  #    # => 'FooMapperKeys'
  #
  def conditional_output_key_column
    self.class.to_s+'Keys'
  end
end
