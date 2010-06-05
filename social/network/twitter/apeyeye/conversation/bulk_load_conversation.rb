#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'json'
require 'cassandra' ; include Cassandra::Constants

Settings.define :keyspace, :default => 'Twitter', :description => 'Cassandra keyspace'
LOG_INTERVAL = 1_000 # emit a statement every LOG_INTERVAL repetition


#
# Load precomputed json data into the ApeyEye database.
#
#   ~/ics/icsdata/social/network/twitter/utils/apeyeye/bulk_loader.rb --dataset=influence --rm --run /data/sn/tw/fixd/infl_metrics/reply_json /tmp/bulkload/influence
#
#
class SimpleMapper < Wukong::Streamer::RecordStreamer
  def process rsrc, user_a_id, user_b_id, *args
    yield [rsrc, user_a_id, user_b_id, *args] unless (user_a_id.to_i == 0) || (user_b_id.to_i == 0)
  end
end


class BulkLoader < Wukong::Streamer::AccumulatingReducer
  attr_accessor :a_replies_b
  def initialize *args
    super *args
    @iter = 0
  end

  def cassandra_db
    @cassandra_db ||= Cassandra.new(Settings.keyspace, %w[ 10.194.11.47 10.194.61.123 10.194.61.124 10.194.99.239 10.195.219.63 10.212.102.208 10.212.66.132 10.218.55.220 ].map{|s| "#{s}:9160"})
  end

  def get_key rsrc, user_a_id, user_b_id, *_
    [user_a_id, user_b_id]
  end

  def start! *args
    self.a_replies_b = []
  end

  def accumulate rsrc, user_a_id, user_b_id, *info
    return if (user_a_id.to_i == 0) || (user_b_id.to_i == 0)
    self.a_replies_b << info.map(&:to_i)
  end

  def finalize &block
    return if self.key.blank?
    user_a_id, user_b_id = self.key
    return if (user_a_id.to_i == 0) || (user_b_id.to_i == 0)
    self.a_replies_b.uniq!
    value_hsh  = { :user_a_id => user_a_id.to_i, :user_b_id => user_b_id.to_i, :a_replies_b => a_replies_b }
    # yield [user_a_id, user_b_id, value_hsh].inspect
    dump_into_db user_a_id, user_b_id, value_hsh, &block
  end

  def dump_into_db user_a_id, user_b_id, value_hsh, &block
    begin
      cassandra_db.insert(:Index, user_a_id, { user_b_id => {
          "a_replies_b_json" => value_hsh.to_json }},
        :consistency => Cassandra::Consistency::ANY)
    rescue StandardError => e ; warn "Insert failed: #{e}" ; @cassandra_db = nil ; sleep 2 ; end
    log_sometimes user_a_id, user_b_id, &block
  end

  def log_sometimes *stuff
    if (@iter+=1) % LOG_INTERVAL == 0
      yield([@iter, *stuff]) ; $stderr.puts [@iter, *stuff].join("\t")
    end
  end
end

Wukong::Script.new(
  SimpleMapper,
  BulkLoader,
  :sort_fields => 3,
  :partition_fields => 3
  ).run
