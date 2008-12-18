#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'active_support'
require 'faster_csv'
require 'imw' ; include IMW
require 'hadoop_utils'; include HadoopUtils
# as_dset __FILE__
require 'twitter_flat_model'

def load_line line
  line = line.chomp
  begin
    line.parse_tsv
  rescue
    warn "\n\n!!!!!!!Couldn't parse '#{line}'\n\n"
    []
  end
end

def emit_scrape_request id, context, page
  out_key = [id, context, page].join('-')
  puts [out_key, 'scrape_request', id, context, page].to_tsv
end

$stdin.each do |line|
  key, item_key, *vals = load_line line
  klass = key.to_s.camelize.constantize
  #p [key, klass, klass.members, vals[0..(klass.members.length-1)]]

  thing = klass.new(*vals[0..(klass.members.length-1)])
  case thing
  when TwitterUser, TwitterUserPartial
    (1 .. (thing.followers_count.to_i / 100.0).ceil).each do |page| emit_scrape_request(thing.id, :followers, page) end
    (1 .. (thing.friends_count.to_i   / 100.0).ceil).each do |page| emit_scrape_request(thing.id, :friends, page) end if thing.is_a?(TwitterUser)
    emit_scrape_request thing.id, :user, 1
  # when ScrapedFileListing
    #
  else
    raise "Don't know what to do with '#{key}'"
  end
end

