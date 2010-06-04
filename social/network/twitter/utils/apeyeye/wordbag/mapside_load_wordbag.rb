#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'json'
require 'cassandra' ; include Cassandra::Constants

Settings.define :keyspace, :default => 'Twitter', :description => 'Cassandra keyspace'
LOG_INTERVAL = 1_000 # emit a statement every LOG_INTERVAL repetition

class SimpleMapper < Wukong::Streamer::RecordStreamer

  def initialize *args
    super *args
    @iter = 0
  end

  def process user, wordbag, &block
    dump_into_db user, wordbag, &block
  end

  def cassandra_db
    @cassandra_db ||= Cassandra.new(Settings.keyspace, %w[ 10.194.11.47 10.194.61.123 10.194.61.124 10.194.99.239 10.195.219.63 10.212.102.208 10.212.66.132 10.218.55.220 ].map{|s| "#{s}:9160"})
  end

  def dump_into_db user, wordbag, &block
    user_id_key = ((user =~ /^\d+$/) ? 'user_id' : 'screen_name')
    begin
      case user_id_key
      when 'user_id' then
        cassandra_db.insert(:Users, user, { "wordbag_json" => wordbag }, :consistency => Cassandra::Consistency::ANY)
      when 'screen_name' then
        cassandra_db.insert(:Usernames, user, { "wordbag_json" => wordbag }, :consistency => Cassandra::Consistency::ANY)
      end
    rescue StandardError => e ; warn "Insert failed: #{e}" ; @cassandra_db = nil ; sleep 2 ; end
    log_sometimes user, wordbag, &block
  end

  def log_sometimes user, wordbag, &block
    if (@iter+=1) % LOG_INTERVAL == 0
      yield([@iter, *stuff]) ; $stderr.puts [@iter, *stuff].join("\t")
    end
  end

end

Wukong::Script.new(
  SimpleMapper,
  nil
  ).run
