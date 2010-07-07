#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
NO_DB = false  # needs to be initialized before wuclan model
require 'wuclan/twitter';
require 'wuclan/twitter/parse';
require 'wuclan/twitter/scrape'; include Wuclan::Twitter::Scrape

class TwitterSearchRequestParser < Wukong::Streamer::StructStreamer
  #
  # Object: parse thyself.
  #

  def process request, *args, &block
    request.parse(*args) do |obj|
      # next if obj.blank? || obj.is_a?(BadRecord)
      yield obj
    end
  end
end

# Go, script, go!
Wukong::Script.new(
  TwitterSearchRequestParser,
  nil,
  :reuse_jvms       => true,
  :map_speculative => "false"
  ).run
