#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'    ; include Wukong
require 'cassandra' ; include Cassandra::Constants

# Address       Status     Load          Range                                      Ring
#                                        oCS61vbuHm16Ebet                           
# 10.244.191.178Up         554 bytes     7I3nWSCieE5suAwJ                           |<--|
# 10.243.19.223 Up         1.08 KB       Sg8HIJxekRRRMMnc                           |   ^
# 10.243.17.219 Up         829 bytes     UQcJBHiXEk5sijAV                           v   |
# 10.245.70.85  Up         829 bytes     lsAOnAOUhCh6NU09                           |   ^
# 10.244.206.241Up         554 bytes     oCS61vbuHm16Ebet                           |-->|
  
class CassandraBatchMapper < Wukong::Streamer::Base
  attr_accessor :batch_count, :batch_record_count
  CASSANDRA_DB_SEEDS = %w[10.244.191.178 10.243.19.223 10.243.17.219 10.245.70.85 10.244.206.241].map{ |s| s.to_s+':9160'}
  BATCH_SIZE = 100

  def cassandra_db
    @cassandra_db ||= Cassandra.new('test_a', CASSANDRA_DB_SEEDS)
  end
  
  def initialize *args
    super *args
    self.batch_count = 0
    self.batch_record_count = 0
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

  def process line, &blk
    insert_cruft(line) do |word|
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

  def insert_cruft word, &blk
    cassandra_db.insert(:words, word.strip, "time" => Time.now.to_i.to_s) unless word.blank?
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
