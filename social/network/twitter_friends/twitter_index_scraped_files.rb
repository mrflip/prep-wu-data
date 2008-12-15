#!/usr/bin/env ruby
require 'fileutils'; include FileUtils

FILENAME_RE =  %r{^([%\w]+?)+\.json%3Fpage%3D(\d+)\+\d{8}-\d{6}\.json$}
#
# list all files into a TSV
#
def dump_listing listing_filename, scrape_session, context, resource
  if File.exists?(listing_filename) then warn "Skipping #{context} for #{scrape_session}: '#{listing_filename}' exists"; return ; end
  scrape_session_n = scrape_session.gsub(/_/, '')
  File.open(listing_filename, "w") do |listing_file|
    # let ls do all the hard work
    `ls -lR #{scrape_session}/#{resource}`.split(/\n/)[2..-1].each do |line|
      # track_count "#{scrape_session}-#{context}", 100000
      _, _, _, _, size, dt, tm, file = line.split(/\s+/)
      m = FILENAME_RE.match(file)
      if !m then warn "Can't grok filename #{file}"
      else
        screen_name, page, *_ = m.captures
        screen_name.gsub!(/%5F/, '_')
      end
      listing_file << [scrape_session_n, context, size, "#{dt} #{tm}", screen_name, page , file ].join("\t")+"\n"
    end
  end
end

#
# Emit MySQL command to load the listing
#
def bulk_load_mysql listing_filename
  query = %Q{
    LOAD DATA INFILE '#{listing_filename}'
      REPLACE INTO TABLE `imw_twitter_graph`.`scraped_file_index`
      FIELDS TERMINATED BY '\\t' ESCAPED BY ''
      LINES  TERMINATED BY '\\n'
      (`scrape_session`, `context`, `size`, `scraped_at`, `screen_name`, `page`, `filename`)
    ;
  }.gsub(/\n/," ")
  puts query
  $stdout.flush
end

#
# Walk each scrape session's file collection
# making, then importing, its listing
#
RIPD_DIR    = File.dirname(__FILE__)+'/ripd'
LISTING_DIR = '/data/rawd/social/network/twitter_friends/ripd_listings'
cd RIPD_DIR do
  # Visit each scrape_session
  Dir['*'].each do |scrape_session|
    [
      [ :user,            'users/show'],
      [ :friends,         'statuses/friends'],
      [ :followers,       'statuses/followers'],
    ].each do |context, resource|
      listing_filename = File.join(LISTING_DIR, "#{scrape_session}-#{context}-lslr.tsv")
      $stderr.puts listing_filename
      dump_listing listing_filename, scrape_session, context, resource
      bulk_load_mysql listing_filename
    end
  end
end


# UPDATE scraped_file_index sfi, twitter_user_partials u
#   SET sfi.twitter_user_id = u.id
#   WHERE sfi.twitter_user_id IS NULL
#   AND     sfi.screen_name = u.screen_name
UPDATE scrape_requests req, scraped_file_index sfi
  SET           req.scraped_at = sfi.scraped_at, req.result_code = (IF sfi.size=0, NULL, 200)
  WHERE sfi.twitter_user_id     = req.twitter_user_id
    AND         sfi.context             = req.context
    AND sfi.page                        = req.page
    AND         sfi.twitter_user_id < 400 AND page < 10
