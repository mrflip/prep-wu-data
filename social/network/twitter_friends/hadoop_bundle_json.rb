#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'imw' ; include IMW
require 'twitter_profile_model'
require 'fileutils'; include FileUtils
as_dset __FILE__

RIPD = '/home/flip/ics/data/ripd/'
RAWD = '/home/flip/ics/data/rawd/keyed'

DIR_TO_RESOURCE =  {
  'users/show'         => :raw_userinfo,
  'statuses/friends'   => :raw_friends,
  'statuses/followers' => :raw_followers
}
def key_from_filename filename
  # file time
  timestamp = File.mtime(filename).strftime("%Y%m%d%H%M%S")
  if m = %r{^#{RIPD}(\w+/\w+)/_(..?)/(\w+?)\.json(?:%3Fpage%3D(\d+))?$}.match(filename)
    dir, prefix, screen_name, page = m.captures
    [ DIR_TO_RESOURCE[dir], screen_name, page, timestamp ]
  else
    raise "Can't grok filename #{filename}"
  end
end


$stdin.each do |filename|
  track_count filename[0..1].downcase
      next unless File.size(filename) > 0
      resource, screen_name, page, timestamp = key_from_filename filename
      key = [resource, screen_name, page, timestamp].join("-")
      f << "#{key}\t#{File.read(filename)}\n"
    end
  end
end
