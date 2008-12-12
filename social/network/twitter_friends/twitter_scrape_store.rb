
class TwitterScrapeStore
  attr_accessor :ripd_base
  def initialize ripd_base
    self.ripd_base  = ripd_base
  end

  #
  # apply block to each scrape session directory
  #
  def each_scrape_session &block
    cd(path_to(:ripd_root)) do
      Dir[path_to(self.ripd_base, "*")].each(&block)
    end
  end

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
        # Stuff each file in this session into
        Dir["#{dir}/*"].each do |ripd_file|
          track_count(dir, 1_000)
          scrape_file = TwitterScrapeFile.new_from_file(ripd_file); next unless scrape_file
          screen_name, twitter_id = [scrape_file.screen_name, scrape_file.twitter_id]
          if ! twitter_id then warn "Missing ID for #{screen_name} in #{ripd_file}"; next end
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
