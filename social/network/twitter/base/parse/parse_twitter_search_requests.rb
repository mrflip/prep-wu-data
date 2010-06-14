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
    self.db_seeds = %w[ 10.195.9.124 10.242.81.156 10.194.186.32 10.196.202.63 10.194.186.95 10.195.162.47 10.196.186.112 ].map{|s| "#{s}:9160"}.sort_by{ rand }    
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
