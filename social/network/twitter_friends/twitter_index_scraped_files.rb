#!/usr/bin/env ruby
require 'rubygems'
# require 'json'
# require 'imw' ; include IMW
# # require 'imw/dataset/datamapper'
# as_dset __FILE__
require 'fileutils'; include FileUtils
require 'ruby-prof'

# # ===========================================================================
# # #
# # # Setup database
# # #
# DataMapper.logging = true
# dbparams = IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_twitter_graph' })
# DataMapper.setup_remote_connection dbparams


# for dir in */*/* ; do rsrc=`echo $dir|ruby -ne 'puts $_.gsub(/\W/,"-")'` ; echo $rsrc ; time
# ls -lR $dir > /data/rawd/social/network/twitter_friends/ripd_listings/${rsrc}lslr.txt ; done

# # ===========================================================================
# #
# # Bulk import file tree
# #
# def mass_queue_requests_query table, context, id_chunk
#   query = %Q{
#     LOAD DATA INFILE '/data/rawd/social/network/twitter_friends/ripd_listings/_20081126-statuses-followers-lslr.txt'
#       REPLACE INTO TABLE `imw_twitter_graph`.`scraped_file_index`
#       FIELDS TERMINATED BY ' ' OPTIONALLY ENCLOSED BY '' ESCAPED BY ''
#       LINES  TERMINATED BY '\n'
#       IGNORE 2 LINES
#       (@dummy, @dummy, @dummy, @dummy, `size`, @scraped_date, @scraped_time, `filename`)
#       SET
#         `scraped_at`    = CONCAT(@scraped_date, " ", @scraped_time ),
#         `context`       = "followers",
#         `scrape_session` = '20081126'
#     }
#   repository(:default).adapter.execute( query )
#   puts query
# end

RIPD_DIR    = File.dirname(__FILE__)+'/ripd'                    # path_to(:ripd)
LISTING_DIR = '/data/rawd/social/network/twitter_friends/ripd_listings'      #path_to(:rawd, 'ripd_listings')

# Profile the code
RubyProf.start

# LSLR_RE = /\A[rwx\-]+\s+\d+\s+\w+\s+\w+\s+(\d+)\s+(\d{4}-\d{2}-\d{2}\s\d{2}:\d{2})\s+([\w\.\-%\+]+)\z/
LSLR_RE = /\A.+
   (\d+)\s+
   ([\d\-]{10} [\d\:]{5})\s+
   ([\w\.\-%\+]+)\z/x
cd RIPD_DIR do
  [
    [ :user, 'users/show'],
  ].each do |context, resource|
    Dir['*{1126,120[123]}'].each do |scrape_session|
      scrape_session_n = scrape_session.gsub(/_/, '')
      puts "#{scrape_session}-#{context}"
      str_head = "#{scrape_session_n}\t#{context}\t"
      listing_filename = File.join(LISTING_DIR, "#{scrape_session}-lslr.tsv")

      File.open(listing_filename, "w") do |listing_file|
        `ls -lR #{scrape_session}/#{resource}`.split(/\n/)[2..-1].each do |line|
          # # track_count "#{scrape_session}-#{context}", 100000
          # # m = LSLR_RE.match(line.chomp) or next
          # # listing_file << line.chomp.gsub(LSLR_RE, "#{scrape_session_n}\t#{context}\t\\1\t\\2 \\3\t\\4\n")
          # mode, _lk, _u, _g, size, dt, tm, file = line.split(/\s+/)
          # # listing_file << [scrape_session_n, context, size, "#{dt} #{tm}", file ].join("\t")+"\n"
          # listing_file << "#{str_head}#{size}\t#{dt} #{tm}\t#{file}"
          listing_file << line.gsub(/ +/, "\t")+"\n"
        end
      end
      # `ls -lR #{scrape_session}/#{resource} | tail -n +3 | perl -pe 's/ +/\\t/g' > #{listing_filename}`
    end
  end
end

# Print a flat profile to text
result = RubyProf.stop
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT, 0)
