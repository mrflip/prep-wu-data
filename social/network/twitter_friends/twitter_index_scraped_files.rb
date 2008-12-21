#!/usr/bin/env ruby
require 'imw'; include IMW;
require 'fileutils'; include FileUtils
require 'hadoop_utils'; include HadoopUtils
as_dset __FILE__

FILENAME_RE =  %r{^([%\w]+?)+\.json%3Fpage%3D(\d+)\+\d{8}-\d{6}\.json$}
#
# list all files into a TSV
#
def dump_listing listing_filename, scrape_session, context, resource
  if File.exists?(listing_filename) then
    $stderr.print "%s-%s (exists)\t"%[context, scrape_session];
    return ;
  end
  scrape_session_n = scrape_session.gsub(/_/, '')
  File.open(listing_filename, "w") do |listing_file|
    $stderr.print "%s-%s (listing)\t"%[context, scrape_session];
    # let ls do all the hard work
    files = `ls -lR #{scrape_session}/#{resource}`.split(/\n/)[2..-1] or return
    files.each do |line|
      # track_count "#{scrape_session}-#{context}", 100000
      _, _, _, _, size, dt, tm, file = line.split(/\s+/)
      m = FILENAME_RE.match(file)
      if !m then warn "Can't grok filename #{file}"
      else
        screen_name, page, *_ = m.captures
        screen_name.gsub!(/%5F/, '_')
      end
      item_key = [screen_name, context, page].join('-')
      scraped_at = repair_date( "#{dt} #{tm}" )
      listing_file << ['scraped_file', item_key, scraped_at, screen_name, context, page, size, scrape_session_n ].join("\t")+"\n"
    end
  end
end

#
# Walk each scrape session's file collection
# making, then importing, its listing
#
RIPD_DIR    = File.dirname(__FILE__)+'/ripd'
LISTING_DIR = path_to(:rawd, 'ripd_listings')
cd RIPD_DIR do
  # Visit each scrape_session
  Dir['*'].sort.each do |scrape_session|
    [
      [ :user,            'users/show'],
      [ :friends,         'statuses/friends'],
      [ :followers,       'statuses/followers'],
    ].each do |context, resource|
      listing_filename = File.join(LISTING_DIR, "#{scrape_session}-#{context}-lslr.tsv")
      dump_listing listing_filename, scrape_session, context, resource
      # bulk_load_mysql listing_filename
    end
  end
  $stderr.puts "done."
end


# #
# # Emit MySQL command to load the listing
# #
# def bulk_load_mysql listing_filename
#   query = %Q{
#     LOAD DATA INFILE '#{listing_filename}'
#       REPLACE INTO TABLE `imw_twitter_graph`.`scraped_file_index`
#       FIELDS TERMINATED BY '\\t' ESCAPED BY ''
#       LINES  TERMINATED BY '\\n'
#       (`scrape_session`, `context`, `size`, `scraped_at`, `screen_name`, `page`, `filename`)
#     ;
#   }.gsub(/\n/," ")
#   puts query
#   $stdout.flush
# end

# UPDATE scraped_file_index sfi, twitter_user_partials u
#   SET sfi.twitter_user_id = u.id
#   WHERE sfi.screen_name = u.screen_name
#   AND   sfi.twitter_user_id IS NULL
#
# UPDATE scrape_requests req, scraped_file_index sfi
#   SET           req.scraped_at = sfi.scraped_at, req.result_code = IF(sfi.size=0, NULL, 200)
#   WHERE sfi.twitter_user_id     = req.twitter_user_id
#     AND         sfi.context     = req.context
#     AND         sfi.page        = req.page
#     AND                 req.scraped_at IS NULL

# SELECT COUNT(*),
#         COUNT(scraped_at), COUNT(*)-COUNT(scraped_at) AS remaining,
#         COUNT(result_code), COUNT(scraped_at)-COUNT(result_code) AS damaged, s.* FROM scrape_requests s
# GROUP BY context
