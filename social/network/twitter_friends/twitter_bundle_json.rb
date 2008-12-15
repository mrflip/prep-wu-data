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
    twitter_ids_filename = path_to(:fixd, "dump/user_names_and_ids-2.tsv")
    FasterCSV.open(twitter_ids_filename, :col_sep => "\t").readlines.each do |screen_name, id, pages|
      @twitter_ids[screen_name] = id
    end
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
      #
      # Dump to a keyed file
      #
      keyed_filename = path_to(keyed_dir, "#{context}-keyed.tsv")
      if File.exists?(keyed_filename) then announce("skipping #{context} for #{scrape_session_dir}: keyed file exists"); next; end
      File.open(keyed_filename, "w") do |keyed_file|
        #
        # Stuff each file in this session into a bulk keyed file.
        #
        Dir["#{dir}/*"].sort.each do |ripd_file|
          scrape_file = TwitterScrapeFile.new_from_file(ripd_file); next unless scrape_file
          screen_name, twitter_id = [scrape_file.screen_name, scrape_file.twitter_id]
          if (! twitter_id) && (context != :user) then MISSING_IDS_FILE << "#{screen_name}\t#{ripd_file}\n"; next ; end
          twitter_id = "%012d"%[twitter_id]
          contents = File.open(ripd_file).read       ; next if contents.blank?
          warn "Tabs or carriage returns in #{ripd_file}" if contents =~ /[\t\n\r]/
          keyed_file << [ screen_name, twitter_id, context, scrape_file.page, scrape_file.cached_uri.timestamp, contents ].join("\t")+"\n"
        end
      end
    end
  end

  def bundle_scrape_sessions keyed_base
    each_scrape_session do |scrape_session_dir|
      bundle_scrape_session keyed_base, scrape_session_dir
    end
  end
  #
  # apply block to each scrape session directory
  #
  def each_scrape_session &block
    cd(path_to(:ripd_root)) do
      # 1204,1205,1206,1207,1208,1209,1203,1202,1201,
      # 1210,          1211,1212,1213,1209,1208,1207,1206,1205,
      Dir[path_to(self.ripd_base, "*")].each(&block)
    end
  end

end

ripd_base  = "_com/_tw/com.twitter"
keyed_base = path_to(:rawd, "keyed")
TwitterScrapeStore.new(ripd_base).bundle_scrape_sessions(keyed_base)

# for fullpath in /workspace/flip/data/rawd/social/network/twitter_friends/keyed/_2* ; do file=`basename $fullpath` ; echo $file ; hadoop dfs -mkdir rawd/keyed/$file ; hadoop dfs -copyFromLocal $fullpath/* rawd/keyed/$file/ ; done
#
# ( ( ls -l ~/ics/pool/social/network/twitter_friends/rawd/keyed/*/* ; ssh lab1 'ls -l ~/ics/pool/social/network/twitter_friends/rawd/keyed/*/*' ; ssh lab3 'ls -l ~/ics/pool/social/network/twitter_friends/rawd/keyed/*/*' ) | cut -c 23-34,114-145 ; ( hdp-ls rawd/keyed/'*/*' | cut -c31-42,82- ) ) | sort -k2
#
#
# 1813810    1.8G _20081126
# 3682703    3.6G _20081127
# 3246424    3.1G _20081128
# 3909506    3.8G _20081129
# 1622336    1.6G _20081130
# 1765025    1.7G _20081201
# 1081432    1.1G _20081202
# 1038394   1015M _20081203
# 2047641    2.0G _20081204
# 1921816    1.9G _20081205
# 1268739    1.3G _20081206
# 3130710    3.0G _20081207
# 3471897    3.4G _20081208
# 3411368    3.3G _20081209
# 4469113    4.3G _20081210
# 4950980    4.8G _20081211
# 4705911    4.5G _20081212
# 1416833    1.4G _20081213
#
# 1126  16       30436  _20081126
# 1127  30       60447  _20081127
# 1128  30       59122  _20081128
# 1129  38       80789  _20081129
# 1130           67549  _20081130
# 1201           53823  _20081201
# 1202           36845  _20081202
# 1203           26158  _20081203
# 1204   9       54115  _20081204
# 1205   9      369706  _20081205
# 1206   6      312912  _20081206
# 1207  15      360588  _20081207
# 1208          342423  _20081208
# 1209          432138  _20081209
# 1210  20      385150  _20081210
# 1211  21      356869  _20081211
# 1212           88921  _20081212
# 1213           49857  _20081213
#
# Tabs or carriage returns in _com/_tw/com.twitter/_20081211/users/show/sorties.json%3Fpage%3D1+20081211-041228.json
# I, [20081213-18:07:59 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081126/statuses/friends: 0
# I, [20081213-18:08:00 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081126/statuses/friends: 0
# I, [20081213-18:08:07 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081126/statuses/followers: 0
# I, [20081213-18:23:23 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081126/statuses/followers: 30000
#
# I, [20081213-18:23:37 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081127/statuses/followers: 0
# I, [20081213-18:53:12 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081127/statuses/followers: 60000
#
# I, [20081213-18:53:31 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081128/statuses/followers: 0
# I, [20081213-19:22:58 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081128/statuses/followers: 59000
# I, [20081213-19:23:08 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081129/statuses/friends: 0
# I, [20081213-19:50:51 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081129/statuses/friends: 57000
# I, [20081213-19:51:11 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081129/statuses/followers: 0
# I, [20081213-20:02:20 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081129/statuses/followers: 23000
#
# I, [20081213-20:02:31 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081130/users/show: 0
# I, [20081213-20:14:19 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081130/users/show: 34000
# I, [20081213-20:14:28 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081130/statuses/friends: 0
# I, [20081213-20:24:47 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081130/statuses/friends: 21000
# I, [20081213-20:25:01 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081130/statuses/followers: 0
# I, [20081213-20:30:23 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081130/statuses/followers: 11000
# I, [20081213-20:30:45 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081201/users/show: 0
# I, [20081213-20:35:26 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081201/users/show: 13000
# I, [20081213-20:35:39 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081201/statuses/friends: 0
#
# I, [20081213-20:46:34 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081201/statuses/friends: 23000
# I, [20081213-20:46:49 #30034]  INFO -- : count of  com/ tw/com.twitter/ 20081201/statuses/followers: 0
#
# I, [20081213-19:28:26 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081204/statuses/followers: 0
# I, [20081213-19:33:53 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081204/statuses/followers: 24000
# I, [20081213-19:33:58 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081204/statuses/friends: 0
# I, [20081213-19:38:59 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081204/statuses/friends: 30000
#
# I, [20081213-19:40:18 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081205/users/show: 0
# I, [20081213-19:47:12 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081205/users/show: 356000
# I, [20081213-19:47:15 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081205/statuses/followers: 0
# I, [20081213-19:48:59 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081205/statuses/followers: 10000
# I, [20081213-19:49:04 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081205/statuses/friends: 0
# I, [20081213-19:49:28 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081205/statuses/friends: 2000
#
# I, [20081213-19:50:41 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081206/users/show: 0
# I, [20081213-19:56:39 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081206/users/show: 312000
#
# I, [20081213-19:58:25 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081207/users/show: 0
# I, [20081213-20:04:19 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081207/users/show: 306000
# I, [20081213-20:04:29 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081207/statuses/followers: 0
# I, [20081213-20:13:02 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081207/statuses/followers: 54000
#
# I, [20081213-20:13:56 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081208/users/show: 0
# I, [20081213-20:18:32 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081208/users/show: 252000
# I, [20081213-20:18:54 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081208/statuses/followers: 0
# I, [20081213-20:30:29 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081208/statuses/followers: 89000
# I, [20081213-20:31:39 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081209/users/show: 0
# I, [20081213-20:38:02 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081209/users/show: 329000
# I, [20081213-20:38:22 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081209/statuses/followers: 0
# I, [20081213-20:47:58 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081209/statuses/followers: 102000
#
# I, [20081213-20:48:00 #11635]  INFO -- : count of  com/ tw/com.twitter/ 20081212/users/show: 0
#
# I, [20081213-19:30:33 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081210/statuses/followers: 0
# I, [20081213-19:43:01 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081210/statuses/followers: 101000
# I, [20081213-19:43:47 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081210/statuses/friends: 0
# I, [20081213-19:52:33 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081210/statuses/friends: 277000
# I, [20081213-19:52:35 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081210/users/show: 0
# I, [20081213-19:52:47 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081210/users/show: 5000
#
# I, [20081213-19:53:01 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081211/statuses/followers: 0
# I, [20081213-19:59:44 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081211/statuses/followers: 117000
# I, [20081213-20:00:07 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081211/statuses/friends: 0
# I, [20081213-20:13:19 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081211/statuses/friends: 191000
# I, [20081213-20:13:32 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081211/users/show: 0
# I, [20081213-20:14:53 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081211/users/show: 48000
#
# I, [20081213-20:14:55 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081212/statuses/followers: 0
# I, [20081213-20:21:53 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081212/statuses/followers: 30000
# I, [20081213-20:22:07 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081212/statuses/friends: 0
# I, [20081213-20:33:21 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081212/statuses/friends: 53000
# I, [20081213-20:33:32 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081212/users/show: 0
# I, [20081213-20:33:55 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081212/users/show: 4000
#
# I, [20081213-20:34:00 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081213/statuses/followers: 0
# I, [20081213-20:36:21 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081213/statuses/followers: 12000
# I, [20081213-20:36:33 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081213/statuses/friends: 0
# I, [20081213-20:39:18 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081213/statuses/friends: 23000
# I, [20081213-20:39:22 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081213/users/show: 0
# I, [20081213-20:41:12 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081213/users/show: 13000
#
# I, [20081213-20:41:30 #4394]  INFO -- : count of  com/ tw/com.twitter/ 20081209/statuses/followers: 0


# DIR_TO_RESOURCE =  {
#   'users/show'         => :raw_userinfo,
#   'statuses/friends'   => :raw_friends,
#   'statuses/followers' => :raw_followers
# }
# %r{^ripd/(\w+/\w+)/_(..?)/(\w+?)\.json(?:%3Fpage%3D(\d+))?$}.match(filename)
