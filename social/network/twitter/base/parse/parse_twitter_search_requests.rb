#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'wuclan/twitter';
require 'wuclan/twitter/parse';
require 'wuclan/twitter/scrape'; include Wuclan::Twitter::Scrape
require File.dirname(__FILE__)+'/cassandra_db'

class TwitterSearchRequestParser < Wukong::Streamer::CassandraStreamer
  include Wukong::Streamer::StructRecordizer
  #
  # Object: parse thyself.
  #

  def initialize *args
    self.db_seeds = CASSANDRA_DB_SEEDS
    self.column_space = "Twitter"
    self.batch_size = 50
    super(*args)
  end

  def process request, *args, &block
    request.parse(args, cassandra_db) do |obj|
      # next if obj.blank? || obj.is_a?(BadRecord)
      yield obj
    end
  end
end

# Go, script, go!
Wukong::Script.new(
  TwitterSearchRequestParser,
  nil
  ).run
