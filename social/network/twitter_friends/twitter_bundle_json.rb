#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'imw' ; include IMW
require 'twitter_profile_model'
require 'fileutils'; include FileUtils
as_dset __FILE__

DIR_TO_RESOURCE =  {
  'users/show'         => :raw_userinfo,
  'statuses/friends'   => :raw_friends,
  'statuses/followers' => :raw_followers
}
def key_from_filename filename
  timestamp = File.mtime(filename).strftime("%Y%m%d%H%M%S")
  if m = %r{^ripd/(\w+/\w+)/_(..?)/(\w+?)\.json(?:%3Fpage%3D(\d+))?$}.match(filename)
    dir, prefix, screen_name, page = m.captures
    [ DIR_TO_RESOURCE[dir], screen_name, page, timestamp ]
  else
    raise "Can't grok filename #{filename}"
  end
end

Dir["ripd/*/*/*"].each do |dir|
  m = %r{^ripd/(\w+/\w+)/_(..?)$}.match(dir) or raise("can't grok '#{dir}'")
  segment, prefix = m.captures;
  resource = DIR_TO_RESOURCE[segment]; prefix = prefix.downcase
  mkdir_p("rawd/#{resource}")
  dump_filename = "rawd/#{resource}/#{resource}-#{prefix}-raw.tsv"
  next if File.exist?(dump_filename)
  File.open(dump_filename, "w") do |f|
    $stderr.puts "#{Time.now}\tScraping #{resource} - #{prefix}*"
    Dir[dir+'/*'].each do |filename|
      next unless File.size(filename) > 0
      resource, screen_name, page, timestamp = key_from_filename filename
      key = [resource, screen_name, page, timestamp].join("-")
      f << "#{key}\t#{File.read(filename)}\n"
    end
  end
end
