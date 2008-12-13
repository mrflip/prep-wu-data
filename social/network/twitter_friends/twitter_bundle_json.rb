#!/usr/bin/env ruby
require 'imw' ; include IMW
require 'fileutils'; include FileUtils
as_dset __FILE__

require 'faster_csv'
require 'twitter_scrape_model'
require 'twitter_scrape_store'

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

MISSING_IDS_FILE = File.open("fixd/dump/missing_ids_#{Time.now.strftime("%Y%m%d-%H%M%S")}.txt", "w")

TwitterScrapeStore.class_eval do
  #
  # Walk all files in the scraped directory and copy them to the new (correct) file scheme
  #
  #
  # !! NOTE !! the resulting file is NOT a proper tab-separated-values file: the
  # !! contents field is not encoded.  Don't use FasterCSV to decode, just split
  # !! off the first fields: .split("\t", 4)
  #
  def bundle_scrape_session keyed_base, scrape_session_dir
    # Set a place to store the keyed files
    scrape_session_name = File.basename(scrape_session_dir)
    keyed_dir = path_to(keyed_base, scrape_session_name)
    mkdir_p keyed_dir

    # Walk the directories for this session
    Dir[path_to(scrape_session_dir, "*/*")].each do |dir|
      # Find out where we are
      resource = dir.gsub(%r{.*?/(\w+/\w+)\z}, '\1')
      context = TwitterScrapeFile.context_for_resource(resource) # KLUDGE KLUDGE KLUDGE

      # Dump to a keyed file
      keyed_filename = path_to(keyed_dir, "#{context}-keyed.tsv")
      if File.exists?(keyed_filename) then announce("skipping #{context} for #{scrape_session_dir}: keyed file exists"); next; end
      File.open(keyed_filename, "w") do |keyed_file|

        # Stuff each file in this session into a bulk keyed file.
        Dir["#{dir}/*"].each do |ripd_file|
          track_count(dir, 1_000)
          scrape_file = TwitterScrapeFile.new_from_file(ripd_file); next unless scrape_file
          screen_name, twitter_id = [scrape_file.screen_name, scrape_file.twitter_id]
          if (! twitter_id) && (context != :user) then MISSING_IDS_FILE << "#{screen_name}\t#{ripd_file}"; next ; end
          twitter_id = "%012d"%[twitter_id]
          contents = File.open(ripd_file).read       ; next if contents.blank?
          warn "Tabs or carriage returns in #{ripd_file}" if contents =~ /[\t\n\r]/
          keyed_file << [ screen_name, twitter_id, context, contents ].join("\t")+"\n"
        end
      end
    end
  end

  def bundle_scrape_sessions keyed_base
    each_scrape_session do |scrape_session_dir|
      bundle_scrape_session keyed_base, scrape_session_dir
    end
  end
end



ripd_base  = "_com/_tw/com.twitter"
keyed_base = path_to(:rawd, "keyed")
TwitterScrapeStore.new(ripd_base).bundle_scrape_sessions(keyed_base)


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
