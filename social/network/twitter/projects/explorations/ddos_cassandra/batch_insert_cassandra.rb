#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'    ; include Wukong
require 'cassandra' ; include Cassandra::Constants

#
# Need to accumulate the data to insert with an accumulating reducer
# Is it the right thing to do to insert everything that corresponds to
# a single key all at once? This should test this.
#

module BatchInsertCassandra

  CASSANDRA_DB_SEEDS = %w[10.196.225.203 10.196.193.219 10.196.227.79 10.196.227.159 10.196.199.47  10.196.225.171 10.196.162.15].map{ |s| s.to_s+':9160'}

  # link to cassandra db
  def self.cassandra_db
    @cassandra_db ||= Cassandra.new('Twitter', CASSANDRA_DB_SEEDS)
  end

  # simple mapper intended to be used with tweets
  # simply emits ["tweet", tweet_id]
  class Mapper < Wukong::Streamer::RecordStreamer
    def process status_key, status_id, *args
      yield [status_key, status_id]
    end
  end

  # accumulating reducer to stack up all tweets. Once we've accumulated
  # all the tweets we insert their status ids into the db all at once
  class Reducer < Wukong::Streamer::AccumulatingReducer
    attr_accessor :data

    # tells the cassandra db to eat dome data
    def db_insert *args
      columns = args.last
      columns.compact!
      columns.each{|k,v| columns[k] = v.to_s}
      args << {:consistency => Cassandra::Consistency::ANY}
      BatchInsertCassandra.cassandra_db.insert(*args)
    end

    # creates a batch insert job (notice the block)
    def batch_insert &blk
      BatchInsertCassandra.cassandra_db.batch &blk
    end

    def start!  *args
      self.data = {}
    end

    def accumulate status_key, status_id
      self.data[status_id.to_s] = {"status_id" => status_id.to_s}
    end

    def finalize
      batch_insert do
        self.data.each do |status_id, data|
          # inserts happening inside the batch block should not be written until the end
          db_insert(:Statuses, status_id, data)
        end
      end
      # self.data.each do |status_id, data|
      #   yield BatchInsertCassandra.cassandra_db.get(:Statuses, status_id.to_s)
      # end
    end

  end

end

Wukong::Script.new(
  BatchInsertCassandra::Mapper,
  BatchInsertCassandra::Reducer
  ).run

