#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'imw' ; include IMW
require 'imw/extract/html_parser'
require 'imw/dataset/datamapper'
as_dset __FILE__
require 'fileutils'; include FileUtils

#
require 'net/http'

# #
# # Setup database
# #
DataMapper::Logger.new(STDERR, :debug) # watch SQL log -- must be BEFORE call to db setup
dbparams = IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_twitter_friends' })
DataMapper.setup_remote_connection dbparams

class ExpandedUrl
  include DataMapper::Resource
  property :short_url, String, :length => 40, :key => true
  property :dest_url,  String, :length => 1024
end
# ExpandedUrl.auto_upgrade!

File.open('fixd/tinyurls.txt').readlines.each do |line|
  short_urls = JSON.load(line)
  next unless short_urls.is_a? Array
  short_urls.each do |short_url|
    short_url.gsub!(%r{\\/},'/')
    next unless (short_url =~ %r{\Ahttp://tinyurl})
    if short_url.length > 40 then warn "funked up URL #{short_url}" ; next ; end
    next if     ExpandedUrl.first({ :short_url => short_url })
    dest_url = Net::HTTP.get_response(URI.parse(short_url))["location"]
    ExpandedUrl.create({ :short_url => short_url , :dest_url => dest_url })
    sleep 2
  end
end
