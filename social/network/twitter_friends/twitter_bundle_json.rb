#!/usr/bin/env ruby
require 'imw' ; include IMW
require 'fileutils'; include FileUtils
as_dset __FILE__

require 'faster_csv'
require 'twitter_scrape_model'
require 'twitter_flat_model'
require 'twitter_scrape_store'
THIS_DIR = File.dirname(__FILE__)

TwitterScrapeFile.class_eval do
  def twitter_id
    self.class.twitter_ids[screen_name.downcase]
  end

  def self.twitter_ids
    return @twitter_ids if @twitter_ids
    @twitter_ids = ID_LIST
    require THIS_DIR+'/user_names_and_ids'
    announce "OK loaded: #{@twitter_ids.length} IDs ready to recognize"
    @twitter_ids
  end
end

MISSING_IDS_FILE = File.open("fixd/dump/missing_ids_#{Time.now.strftime(DATEFORMAT)}.txt", "w")
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
    #
    # Set a place to store the keyed files
    #
    scrape_session_name = File.basename(scrape_session_dir)
    keyed_dir = path_to(keyed_base, scrape_session_name)
    mkdir_p keyed_dir
    #
    # Walk the directories for this session
    #
    Dir[path_to(scrape_session_dir, "*/*")].each do |dir|
      # Find out where we are
      resource = dir.gsub(%r{.*?/(\w+/\w+)\z}, '\1')
      context = TwitterScrapeFile.context_for_resource(resource) # KLUDGE KLUDGE KLUDGE
      announce dir
      bundle_dir dir, context, keyed_dir
    end
  end

  def bundle_scrape_sessions pathspec, keyed_base
    each_scrape_session(pathspec) do |scrape_session_dir|
      bundle_scrape_session keyed_base, scrape_session_dir
    end
  end

  #
  # Dump to a keyed file
  #
  def bundle_dir dir, context, keyed_dir
    open_keyed_file(keyed_dir, context) do |keyed_file|
      Dir["#{dir}/*"].sort.each do |ripd_file|
        bundle_file ripd_file, context, keyed_file
      end
    end
  end

  #
  # Stuff each file in this session into a bulk keyed file.
  #
  def bundle_file ripd_file, context, keyed_file
    scrape_file = TwitterScrapeFile.new_from_file(ripd_file); return unless scrape_file
    screen_name, twitter_id = [scrape_file.screen_name, scrape_file.twitter_id]
    if (! twitter_id) && (context != :user) then MISSING_IDS_FILE << "#{screen_name}\t#{context}\t#{ripd_file}\n"; return ; end
    twitter_id = "%012d"%[twitter_id.to_i]
    begin
      contents = File.open(ripd_file).read ; return if contents.blank?
    rescue
      return
    end
    warn "Tabs or carriage returns in #{ripd_file}" if contents =~ /[\t\n\r]/
    scraped_at = scrape_file.cached_uri.timestamp
    keyed_file << [ screen_name, twitter_id, context, scrape_file.page, scraped_at, contents ].join("\t")+"\n"
  end

  def open_keyed_file keyed_dir, context, &block
    keyed_filename = path_to(keyed_dir, "#{context}-keyed.tsv")
    if File.exists?(keyed_filename) then announce("skipping #{context}: keyed file exists"); return ; end
    File.open(keyed_filename, "w", &block)
  end

  #
  # apply block to each scrape session directory
  #
  def each_scrape_session pathspec, &block
    cd(path_to(:ripd_root)) do
      pathspec.each do |pathspec|
        announce "Parsing #{pathspec}"
        Dir[path_to(self.ripd_base, pathspec)].each(&block)
      end
    end
  end

  def bundle_from_misc_files_list keyed_base, misc_files_list
    open_keyed_file(keyed_base+'/misc', 'misc' ) do |keyed_file|
      File.open(misc_files_list).readlines.each do |line|
        cd(path_to(:ripd_root)) do
          _, context, ripd_file = line.chomp.split "\t"
          if ! File.exists?(ripd_file) then warn "No such file #{ripd_file}" ; next ; end
          bundle_file ripd_file, context, keyed_file
        end
      end
    end
  end
end


ripd_base  = "_com/_tw/com.twitter"
keyed_base = path_to(:rawd, "keyed")
scraper = TwitterScrapeStore.new(ripd_base)

pathspec = ARGV
if pathspec.empty?
  raise "I need a pathspec (relative to ripd_root) to bundle!"
end
scraper.bundle_scrape_sessions(pathspec, keyed_base)
