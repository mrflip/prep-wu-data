#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require File.dirname(__FILE__)+'../../lib/cassandra_db'

class PagerankRectifier < Wukong::Streamer::CassandraStreamer

  def recordize line
    line.split("\t") rescue nil
  end

  def initialize *args
    self.db_seeds = CASSANDRA_DB_SEEDS
    self.column_space = "Twitter"
    self.batch_size = 1
    super(*args)
  end

  def process user_id, rank, list, &blk
    yield [user_id, sn_from_id(user_id), rank]
  end

  def sn_from_id user_id
    return unless user_id
    cassandra_db.get(:Users, user_id.to_s, 'screen_name')
  end

end


if $0 == __FILE__
  # Go script go!
  Wukong::Script.new(
    PagerankRectifier,
    nil,
    :partition_fields => 2,
    :sort_fields      => 3,
    :reuse_jvms       => true
    ).run
end
