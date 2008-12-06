#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'json'
require 'active_support'
require 'imw' ; include IMW
require 'pathname'
# require 'imw/dataset/datamapper'
as_dset __FILE__

# #
# # Setup database
# #
# DataMapper.logging = true
# dbparams = IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_twitter_friends' })
# DataMapper.setup_remote_connection dbparams

LOAD_FILE_DIR = Pathname.new(ARGV[0]).realpath or raise "Please give a directory to load"
LOAD_DATA_INFILE_QUERY = %Q{
  LOAD DATA INFILE '#{LOAD_FILE_DIR}/%s.tsv'
    REPLACE INTO TABLE        `imw_twitter_graph`.`%s`
    COLUMNS
      TERMINATED BY           '\\t'
      OPTIONALLY ENCLOSED BY  '"'
      ESCAPED BY              ''
    LINES STARTING BY         '%s\\t'
    ;
  SELECT NOW(), COUNT(*) FROM `%s`;
}
def load_data_infile table
  prefix = table.to_s.gsub(/twitter_user/, 'user').singularize
  query = LOAD_DATA_INFILE_QUERY % [
    table, table, prefix, table
  ]
  puts query
end

$stderr.print "#{Time.now} - Loading"
[
  :twitter_users,
  # :twitter_user_profiles,
  :twitter_user_styles,
  # :twitter_user_partials,
  # :tweets,
  :tweet_urls,
  :hashtags,
  :a_atsigns_bs,
  :a_follows_bs,
  :a_replied_bs,
  # :scrape_requests,
].each do |table|
  $stderr.print " #{table}"
  load_data_infile table
end
$stderr.puts "."
