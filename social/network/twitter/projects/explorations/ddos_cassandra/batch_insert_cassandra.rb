#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'    ; include Wukong
require 'cassandra' ; include Cassandra::Constants

class CassandraBatchMapper < Wukong::Streamer::Base
  attr_accessor :batch_count, :batch_record_count
  CASSANDRA_DB_SEEDS = %w[10.196.225.203 10.196.193.219 10.196.227.79 10.196.227.159 10.196.199.47 10.196.225.171 10.196.162.15].map{ |s| s.to_s+':9160'}
  BATCH_SIZE = 100

  def cassandra_db
    # @cassandra_db ||= Cassandra.new('Cruft', CASSANDRA_DB_SEEDS)
    @cassandra_db ||= Cassandra.new('Cruft')
  end
  
  def initialize *args
    super *args
    self.batch_count = 0
    self.batch_record_count = 0
    @words = File.open('/usr/share/dict/american-english-insane')
  end
  
  def stream
    while still_lines? do
      start_batch do
        while still_lines? && batch_not_full? do
          line = get_line
          record = recordize(line.chomp) or next
          process(*record) do |output_record|
            emit output_record
          end
          self.batch_record_count += 1
        end
      end
    end
  end

  def process *args, &blk
    insert_cruft do |word|
    # read_cruft do |word|
      yield word
    end
  end
  
  def start_batch &blk
    self.batch_record_count = 0    
    self.batch_count += 1
    cassandra_db.batch(&blk)
  end

  def get_line
    $stdin.gets
  end
  
  def still_lines?
    !$stdin.eof?
  end

  def batch_not_full?
    self.batch_record_count < BATCH_SIZE
  end

  def insert_cruft &blk
    word = @words.gets.strip
    cassandra_db.insert(:OhBaby, word, "time" => Time.now.to_i.to_s) unless word.blank?
    yield word
  end

  def read_cruft &blk
    word = @words.gets.strip
    yield cassandra_db.get(:OhBaby, word) unless word.blank?
  end
  
end

Wukong::Script.new(
  CassandraBatchMapper,
  nil
  ).run
