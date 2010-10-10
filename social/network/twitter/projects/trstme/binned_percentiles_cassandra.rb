#!/usr/bin/env jruby

require 'java'
require 'rubygems'
require 'wukong'
require 'json'

$: << '/home/jacob/Programming/xanthos/lib'
require 'xanthos'

$CLASSPATH << File.dirname(__FILE__)

java_import 'Percentiles'

#
# Once:
#
# $CASSANDRA_HOME/bin/cassandra-cli --host localhost --port 9160
# create keyspace Trstrank with replication_factor=1
# use Trstrank
# create column family FollowPercentiles
# create column family AtsignPercentiles
#

#
# Percentiles using java, more efficient than ruby
#
Float.class_eval do def round_to(x) ((10**x)*self).round.to_f/(10**x) end ; end
Array.class_eval do
  def percentiles
    calculator = Percentiles.new
    calculator.percentiles(self.to_java(:double)).to_a
  end
end

#
# Do nothing more than bin users here, arbitrary and probably bad
#
class Mapper < Wukong::Streamer::RecordStreamer
  def process *args
    return unless args.length == 4
    uid, fo_rank, at_rank, followers  = args
    yield [casebin(logbin(followers)), at_rank]
  end

  def logbin(x)
    begin
      Math.log10(x.to_f).round_to(1)*10
    rescue
      return 0.01
    end
  end

  #
  # Voodoo
  #
  def casebin x
    x = x.to_f
    return x if x < 20.0
    return 25.0 if x < 25.0
    return 30.0 if x < 30.0
    return 31.0
  end

end

#
# Calculate percentile rank for every pr value in a given follower bracket
#
class Reducer < Wukong::Streamer::AccumulatingReducer
  attr_accessor :single_bin, :db

  def initialize *args
    super(*args)
    @db = Xanthos::Cassandra.new("Trstrank", "localhost:9160")
  end

  def start! bin, rank, *_
    self.single_bin = []
  end

  def accumulate bin, rank, *_
    return if self.single_bin.size > 25000 # limit number of records to less than 25k
    rank = rank.to_f.round_to(1)
    self.single_bin << rank
  end

  def finalize
    @db.insert(:AtsignPercentiles, key, {:percentiles => percentile_hash.to_json})
    yield [key, percentile_hash.to_json]
  end

  def percentile_hash
    h = single_bin.sort.percentiles.inject({}){|h,pair| h[pair.first] = pair.last; h}
    h[10.0] = 100.0
    h
  end

end

Wukong::Script.new(
  Mapper,
  Reducer,
  :reduce_tasks => 2
  ).run
