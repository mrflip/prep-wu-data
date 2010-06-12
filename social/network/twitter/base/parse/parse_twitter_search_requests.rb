#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'wuclan/twitter';
require 'wuclan/twitter/parse';
require 'wuclan/twitter/scrape'; include Wuclan::Twitter::Scrape

class TwitterSearchRequestParser < Wukong::Streamer::CassandraStreamer
  include Wukong::Streamer::StructRecordizer
  #
  # Object: parse thyself.
  #

  def initialize *args
    self.db_seeds = "127.0.0.1:9160"
    self.column_space = "Twitter"
    self.batch_size = 10
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
