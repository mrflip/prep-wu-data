#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'json'
require 'active_support'
require 'imw' ; include IMW
require 'pathname'
# require 'imw/dataset/datamapper'
as_dset __FILE__

require 'hadoop_utils'
require 'twitter_flat_model'

raise "Please give a directory to load" unless ARGV[0]
LOAD_FILE_DIR = Pathname.new(ARGV[0]).realpath
DB_NAME = 'imw_twitter_graph'
def load_data_infile thing, fields
  table = thing.to_s.pluralize
  query = %Q{
    LOAD DATA INFILE '#{LOAD_FILE_DIR}/#{thing}.tsv'
      REPLACE INTO TABLE        `#{DB_NAME}`.`#{table}`
      COLUMNS
        TERMINATED BY           '\\t'
        OPTIONALLY ENCLOSED BY  '"'
        ESCAPED BY              ''
      LINES STARTING BY         '#{thing}\\t'
      (@dummy, #{fields.join(",")})
      ;
    SELECT '#{thing}', NOW(), COUNT(*) FROM `#{table}`;
  }
  $stdout.puts query
  $stdout.flush
end



$stderr.print "#{Time.now} - Loading"
[
  # :a_atsigns_b           ,
  # :a_replied_b           ,
  # :hashtag               ,
  # :tweet_url             ,
  # :twitter_user_profile  ,
  # :twitter_user_style    ,
  # :twitter_user          ,
  # :twitter_user_partial  ,
  # :tweet                 ,
  # :a_follows_b           ,
].each do |thing|
  klass = thing.to_s.camelize.constantize
  fields = klass.members
  fields[-1] = :scraped_at
  fields[0]  = :twitter_user_id if [:twitter_user_profile, :twitter_user_style].include?(thing)
  $stderr.print " -- #{thing}"
  #
  # emit mysql bulk loader query
  #
  load_data_infile thing, fields
end
