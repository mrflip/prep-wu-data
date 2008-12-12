#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'imw' ; include IMW
require 'imw/chunk_store/scrape'
include FileUtils
as_dset __FILE__

# Get the password -- keep this file .gitignore'd obvs.
require File.dirname(__FILE__)+'/twitter_pass.rb'

class TwitterScrapeFile
  include ScrapeFile
  attr_accessor :screen_name, :context, :page
  def initialize screen_name, context, page
    self.screen_name = screen_name
    self.context    = context
    self.page       = page
  end
  RESOURCE_PATH_FROM_CONTEXT = {
    :followers => 'statuses/followers', :friends => 'statuses/friends', :user => 'users/show'}
  def resource_path
    RESOURCE_PATH_FROM_CONTEXT[context]
  end
  # Fake the cached_uri path
  def ripd_file
    base_path = "_com/_tw/com.twitter/#{resource_path}"
    prefix    = (screen_name+'.')[0..1]
    slug_path = "_" + prefix.downcase
    filename  = "#{screen_name}.json%3Fpage%3D#{page}"
    path_to(:ripd_root, base_path, slug_path, filename) # :ripd_root
  end
  #
  def rip_uri
    "http://twitter.com/#{resource_path}/#{screen_name}.json?page=#{page}"
  end
end

USERNAMES_FILE = 'fixd/dump/user_names_by_followers_count.tsv'
# USERNAMES_FILE = '/tmp/foo_users.tsv'
File.open(USERNAMES_FILE).each do |line|
  line.chomp!
  screen_name, *rest = line.split(/\t/); next unless screen_name
  track_count(:users, 100)
  [:followers ].each do |context|
    scrape_file = TwitterScrapeFile.new(screen_name, context, 1)
    success = scrape_file.wget :http_user => TWITTER_USERNAME, :http_passwd => TWITTER_PASSWD, :sleep_time => 0
    warn "No yuo on #{screen_name}: #{scrape_file.result_status}" unless success
  end
end

