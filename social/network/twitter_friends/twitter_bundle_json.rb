#!/usr/bin/env ruby
require 'imw' ; include IMW
require 'fileutils'; include FileUtils
as_dset __FILE__

require 'faster_csv'
require 'twitter_scrape_model'

TwitterScrapeFile.class_eval do
  def twitter_id
    self.class.twitter_ids[screen_name]
  end

  def self.twitter_ids
    return @twitter_ids if @twitter_ids
    @twitter_ids = { }
    announce "initial load of IDs file... will take a while"
    twitter_ids_filename = path_to(:fixd, "dump/user_names_and_ids.tsv")
    FasterCSV.open(twitter_ids_filename, :col_sep => "\t").readlines.each do |screen_name, id, pages|
      @twitter_ids[screen_name] = id
    end
    announce "OK loaded: #{@twitter_ids.length} IDs ready to recognize"
    @twitter_ids
  end
end

ripd_base  = "_com/_tw/com.twitter"
keyed_base = path_to(:rawd, "keyed")
CachedUriStore.new(ripd_base, keyed_base).bundle_scrape_sessions





# DIR_TO_RESOURCE =  {
#   'users/show'         => :raw_userinfo,
#   'statuses/friends'   => :raw_friends,
#   'statuses/followers' => :raw_followers
# }
# def key_from_filename filename
#   timestamp = File.mtime(filename).strftime("%Y%m%d%H%M%S")
#   if m = %r{^ripd/(\w+/\w+)/_(..?)/(\w+?)\.json(?:%3Fpage%3D(\d+))?$}.match(filename)
#     dir, prefix, screen_name, page = m.captures
#     [ DIR_TO_RESOURCE[dir], screen_name, page, timestamp ]
#   elsif m = %r{^ripd/(\w+/\w+)/_(..?)/(\w+?(?:%20|&|\-| |\*)\w+?)+\.json(?:%3Fpage%3D(\d+))?$}.match(filename)
#     warn  "Bogus filename #{filename}"; return []
#   else
#     warn "Can't grok filename #{filename}"; return []
#   end
# end
#
#
#   # m = %r{^ripd/(\w+/\w+)/_(..?)$}.match(dir) or raise("can't grok '#{dir}'")
#   # segment, prefix = m.captures;
#   # resource = DIR_TO_RESOURCE[segment]; prefix = prefix.downcase
#   # mkdir_p("rawd/#{resource}")
#   #
#
# def get_dump_filename filename
#   "#{RAWD}/%s" % [ filename.gsub(%r{^ripd/}, '')]
# end
#
# Dir["#{RIPD}/*/*/*"].sort.each do |dir|
#   $stderr.puts "#{Time.now}\tkeying #{dir.gsub(%r{^.*/ripd/}, 'ripd/')}/*"
#   Dir[dir+'/*'].each do |filename|
#     #
#     # output file
#     dump_filename = get_dump_filename filename
#     next if File.exist?(dump_filename)
#     next unless File.size(filename) > 0
#     #
#     # grok existing file
#     resource, screen_name, page, timestamp = key_from_filename(filename)
#     next unless timestamp
#     key = [resource, screen_name, page, timestamp].join("-")
#     mkdir_p File.dirname(dump_filename)
#     File.open(dump_filename, "w") do |f|
#       f << "#{key}\t#{File.read(filename)}\n"
#     end
#   end
# end
