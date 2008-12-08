#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'imw' ; include IMW
require 'imw/extract/html_parser'
require 'imw/dataset/datamapper'
as_dset __FILE__
require 'fileutils'; include FileUtils

#
require 'twitter_profile_model'
require File.dirname(__FILE__)+'/twitter_pass.rb'

#
# wget url_to_get, ripd_file, sleep_time
#
# Crudely scrape a url
#
# get the url
# leave a 0-byte turd on failure to prevent re-fetching; use find ripd/ -size 0 --exec rm {} \; to scrub
# sleeps for sleep_time
#
def wget rip_url, ripd_file, sleep_time=1
  cd path_to(:ripd_root) do
    mkdir_p   File.dirname(ripd_file)
    if File.exists?(ripd_file)
      puts "Skipping #{rip_url}"
    else
      print `wget -nv --timeout=8 --http-user=#{TWITTER_USERNAME} --http-passwd=#{TWITTER_PASSWD} -O'#{ripd_file}' '#{rip_url}' `
      # puts "(sleeping #{sleep_time})" ;
      sleep sleep_time
    end
    success = File.exists?(ripd_file) && (File.size(ripd_file) != 0)
    return success
  end
end

def ripd_file_from_url url
  case
  when m = %r{http://twitter.com/([^/]+/[^/]+)/(..?)([^?]*?)\?page=(.*)}.match(url)
    resource, prefix, suffix, page = m.captures
    "_com/_tw/com.twitter/#{resource}/_#{prefix.downcase}/#{prefix}#{suffix}%3Fpage%3D#{page}"
  when m = %r{http://twitter.com/([^/]+/[^/]+)/(..?)([^?]*?)$}.match(url)
    resource, prefix, suffix = m.captures
    "_com/_tw/com.twitter/#{resource}/_#{prefix.downcase}/#{prefix}#{suffix}"
  else
    warn "Can't grok url #{url}"; return nil
  end
end

File.open('fixd/hadooped/20081206/scrape_requests_rev.tsv').each do |line|
  line.chomp!
  screen_name, *rest = line.split(/\t/)
  track_count    :users, 50
  uri  = "http://twitter.com/users/show/#{screen_name}.json?page=1"
  ripd_file = ripd_file_from_url(uri)
  next unless ripd_file && (ripd_file =~ %r{^_com/_tw})
  success = wget uri, ripd_file, 0
  warn "No yuo on #{screen_name}" unless success
end
