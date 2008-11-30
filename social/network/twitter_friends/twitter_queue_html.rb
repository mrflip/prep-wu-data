#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'imw' ; include IMW
require 'imw/extract/html_parser'
require 'imw/dataset/datamapper'
require 'twitter_profile_model'
as_dset __FILE__

# #
# # Setup database
# #

# DataMapper::Logger.new(STDERR, :debug) # watch SQL log -- must be BEFORE call to db setup
dbparams = IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_twitter_friends' })
DataMapper.setup_remote_connection dbparams


Dir["/data/rawd/social/network/twitter_friends/profiles/twitter_id_*"].each do |dir|
  puts "#{Time.now}\tScraping #{dir.gsub(%r{.*/}, '')}"
  Dir[dir+'/*'].each do |profile_file|
    next unless File.size(profile_file) > 0
    twitter_name = File.basename(profile_file)
    twitter_user = TwitterUser.find_or_create( :twitter_name => twitter_name )
    priority     = twitter_user.twitter_page_rank ? twitter_user.twitter_page_rank.prestige : twitter_user.id
    url          = "http://twitter.com/#{twitter_name}"
    AssetRequest.find_or_create({
        :twitter_user_id => twitter_user.id,
        :user_resource   => 'parse',
        :page            => 1
      }, {
        :uri             => url,
        :priority        => priority,
        :twitter_name    => twitter_name,
      })
  end
end
