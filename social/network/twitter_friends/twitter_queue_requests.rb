#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'imw' ; include IMW
require 'imw/dataset/datamapper'
as_dset __FILE__
require 'fileutils'; include FileUtils
#
require 'twitter_graph_model'
require 'twitter_scrape_model'
require 'twitter_scrape_store'

# ===========================================================================
# #
# # Setup database
# #
DataMapper.logging = true
dbparams = IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_twitter_graph' })
DataMapper.setup_remote_connection dbparams


# for dir in */*/* ; do rsrc=`echo $dir|ruby -ne 'puts $_.gsub(/\W/,"-")'` ; echo $rsrc ; time ls -lR $dir > /data/rawd/social/network/twitter_friends/ripd_listings/${rsrc}lslr.txt ; done

# TwitterScrapeStore.class_eval do
#   #
#   # Walk all files in the scraped directory and validate them as
#   # having been fetched
#   #
#   def mass_validate_scrape_session scrape_session_dir
#     # Walk the directories for this session
#     Dir[path_to(scrape_session_dir, "*/*")].each do |dir|
#       Dir["#{dir}/*"].each do |ripd_file|
#         track_count(dir, 10_000)
#         scrape_file = TwitterScrapeFile.new_from_file(ripd_file); next unless scrape_file
#         next unless scrape_file
#         validate_request ripd_file, scrape_file
#       end
#     end
#   end
#
#   # mass_validate all of the sessions
#   def mass_validate_scrape_sessions
#     each_scrape_session do |scrape_session_dir|
#       mass_validate_scrape_session scrape_session_dir
#     end
#   end
#
#   #
#   # Dump raw MySQL commands to mark this request as complete
#   #
#   def validate_request ripd_file, scrape_file
#     result_code = (File.size(ripd_file) > 0) ? 200 : 'NULL'
#     scraped_at  = File.mtime(ripd_file)
#     puts %Q{
#       UPDATE IGNORE `imw_twitter_graph`.`scrape_requests`
#       SET  `result_code` = #{result_code}, `scraped_at` = '#{scraped_at.strftime("%Y-%m-%d %H:%M:%S")}'
#         WHERE `page`  = #{scrape_file.page} AND `context` = '#{scrape_file.context}' AND `screen_name` = '#{scrape_file.screen_name}'
#         LIMIT 1 ;
#     }.gsub(/\n/, ' ')
#   end
#
# end
#
# ripd_base  = "_com/_tw/com.twitter"
# TwitterScrapeStore.new(ripd_base).mass_validate_scrape_sessions



# ===========================================================================
#
# Bulk insert requests from the user_partials table
#
# Need to have a database table `auxtables`.`ints` with a column `i` that contains 0...2^16
#     (SELECT i FROM `auxtables`.`ints` WHERE i < 10) pg
#
CONTEXT_URI       = { :user => 'users/show', :followers => 'statuses/followers', :friends => 'statuses/friends'}
CONTEXT_PAGELIMIT = { :user => '1', :followers => 'CEILING(u.followers_count/100)', :friends => 'CEILING(u.friends_count/100)'}
ID_CHUNK_SIZE     = 1_000_000
def mass_queue_requests_query table, context, id_chunk
  uri_base  = CONTEXT_URI[context]
  pagelimit = CONTEXT_PAGELIMIT[context]
  case context
  when :user                    then  page_chunks = [ [0, 0] ]
  when :followers, :friends     then  page_chunks = [ [0, 1], [2, 5], [6, 20], [21, 2000] ]
  end
  page_chunks.each do |page_chunk|
    query = %Q{
      INSERT DELAYED IGNORE INTO `scrape_requests`
        (`priority`, `twitter_user_id`, `screen_name`, `context`, `page`, `uri`, `requested_at`, `scraped_at`, `result_code`)
        SELECT     (-followers_count) AS priority,
                   id AS twitter_user_id, screen_name, c.context, pg.page AS page,
                   CONCAT("http://twitter.com/", c.uri_base, "/", screen_name, ".json&page=", pg.page) AS uri,
                   NOW() AS requested_at, NULL AS scraped_at, NULL AS result_code
          FROM     #{table} u,
                   (SELECT "scrape_#{context}" AS context, "#{uri_base}" AS uri_base) c,
                   (SELECT i+1 AS page FROM `auxtables`.`ints` WHERE i BETWEEN #{page_chunk.first} AND #{page_chunk.last} ) pg
          WHERE    id BETWEEN #{ID_CHUNK_SIZE * id_chunk} AND #{ID_CHUNK_SIZE * (id_chunk+1)}
            AND    pg.page <= #{pagelimit} AND u.followers_count >= #{page_chunk.first * 100}
          GROUP BY id, context, page
      ;
    }
    repository(:default).adapter.execute( query )
    # puts query
    # $stdout.flush
  end
end
def mass_queue_requests
  { :twitter_user_partials => [:user, :followers],
    :twitter_users         => [:user, :followers, :friends]
  }.each do |table, contexts|
    contexts.each do |context|
      (1..50).each do |id_chunk|
        mass_queue_requests_query table, context, id_chunk
      end
    end
  end
end
mass_queue_requests


# DELETE twitter_user_partials u
#   FROM twitter_user_partials u,
#    (SELECT screen_name
#       FROM twitter_user_partials
#       GROUP BY screen_name HAVING COUNT(DISTINCT id) > 1) a
#   WHERE u.screen_name = a.screen_name
#

# 2008-12-08
#  170726  statuses/friends
#  318502  statuses/followers
#  975599  users/show
# 1464827  -- total --
