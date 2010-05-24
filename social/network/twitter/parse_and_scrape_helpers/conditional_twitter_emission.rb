#!/usr/bin/env ruby
require 'cassandra'
require 'wukong/keystore/cassandra_conditional_outputter'
CASSANDRA_KEYSPACE = 'Twitter'


module ConditionalTwitterEmission

  include CassandraConditionalOutputter

  def conditional_output_key record
    record.key
  end

  def conditional_output_key_column() "Tweets"; end

  def should_emit? record
    key = conditional_output_key(record)
    if record.class.mutable?
      cached = key_cache.get(conditional_output_key_column, key)
      (cached.blank? || cached['t'].nil? || cached['t'] < record.timestamp)
    else
      super(record)
    end
  end

end
