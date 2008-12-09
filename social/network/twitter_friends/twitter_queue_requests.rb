#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'imw' ; include IMW
require 'imw/dataset/datamapper'
as_dset __FILE__
require 'fileutils'; include FileUtils
require 'scrape'
#
require 'twitter_graph_model'

# #
# # Setup database
# #
# DataMapper.logging = true
dbparams = IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_twitter_graph' })
DataMapper.setup_remote_connection dbparams
# ScrapeRequest.auto_upgrade!

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
    }
    repository(:default).adapter.execute( query )
    puts query
  end
end
def mass_queue_requests
  { :twitter_user_partials => [:user, :followers],
    :twitter_users         => [:user, :followers, :friends]
  }.each do |table, contexts|
    contexts.each do |context|
      (0..18).each do |id_chunk|
        mass_queue_requests_query table, context, id_chunk
      end
    end
  end
end

#
# Dump raw MySQL commands to mark this request as complete
#
def validate_request context, screen_name, page, ripd_file, uri
  # req = ScrapeRequest.first :context => context, :screen_name => screen_name, :page => page 
  # return if !req || req.scraped?
  result_code = (File.size(ripd_file) > 0) ? 200 : 'NULL' 
  scraped_at  = File.mtime(ripd_file)
  # req.update_attributes :scraped_at => scraped_at, :result_code => result_code
  puts %Q{ 
    UPDATE IGNORE `imw_twitter_graph`.`scrape_requests`
    SET  `result_code` = #{result_code}, `scraped_at` = '#{scraped_at.strftime("%Y-%m-%d %H:%M:%S")}' 
      WHERE `page` = #{page} AND `context` = '#{context}' AND `screen_name` = '#{screen_name}' 
      LIMIT 1 ;
  }.gsub(/\n/, ' ')
end
#
# Walk all files in the scraped directory and validate them as 
# having been fetched
#
def mass_validate_requests
  cd path_to(:ripd_root) do
    Dir["_com/_tw/com.twitter/*/u*"].each do |resource|
      Dir["#{resource}/*"].each do |dir|
        Dir["#{dir}/*"].each do |ripd_file|
          track_count :files, 50_000
          resource, screen_name, page, uri = ScrapeRequest.info_from_ripd_file(ripd_file)
          next unless resource && screen_name && page 
          context = "scrape_#{ CONTEXT_URI.invert[resource] }"
          validate_request context, screen_name, page, ripd_file, uri
        end
      end
    end
  end
end

# 2008-12-08
#  170726  statuses/friends
#  318502  statuses/followers
#  975599  users/show
# 1464827  -- total --

# mass_queue_requests
mass_validate_requests


# DELETE twitter_user_partials u
#   FROM twitter_user_partials u,
#    (SELECT screen_name
#       FROM twitter_user_partials
#       GROUP BY screen_name HAVING COUNT(DISTINCT id) > 1) a
#   WHERE u.screen_name = a.screen_name
#
