#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'imw' ; include IMW
require 'twitter_profile_model'
require 'fileutils'; include FileUtils
as_dset __FILE__

RIPD = 'ripd'
RAWD = 'rawd/keyed'


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


  # m = %r{^ripd/(\w+/\w+)/_(..?)$}.match(dir) or raise("can't grok '#{dir}'")
  # segment, prefix = m.captures;
  # resource = DIR_TO_RESOURCE[segment]; prefix = prefix.downcase
  # mkdir_p("rawd/#{resource}")
  #

def get_dump_filename filename
  "#{RAWD}/%s" % [ filename.gsub(%r{^ripd/}, '')]
end

Dir["#{RIPD}/*/*/*"].each do |dir|
  $stderr.puts "#{Time.now}\tkeying #{dir.gsub(%r{^.*/ripd/}, 'ripd/')}/*"
  Dir[dir+'/*'].each do |filename|
    #
    # output file
    dump_filename = get_dump_filename filename
    next if File.exist?(dump_filename)
    next unless File.size(filename) > 0
    mkdir_p File.dirname(dump_filename)
    File.open(dump_filename, "w") do |f|
      #
      # grok existing file
      resource, screen_name, page, timestamp = key_from_filename filename
      key = [resource, screen_name, page, timestamp].join("-")
      f << "#{key}\t#{File.read(filename)}\n"
    end
  end
end
