#!/usr/bin/env ruby
require 'rubygems'
require 'imw' ; include IMW
require 'imw/dataset/datamapper'
as_dset __FILE__
require 'fileutils'; include FileUtils
#
require 'net/http'
require 'twitter_graph_model'
require 'twitter_autourl'

#
# #
# # Setup database
# #
DataMapper.logging = true
dbparams = IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_twitter_graph' })
DataMapper.setup_remote_connection dbparams
CHUNK_SIZE = 1000

def repair_url src_url
  src_url = src_url.gsub(%r{(http://is.gd/\w+)[-/]}, '\1')
  src_url
end


chunks =  ExpandedUrl.count( :dest_url => nil, :scraped_at => nil ) / CHUNK_SIZE
(0..chunks).each do |chunk|
  ExpandedUrl.all( :dest_url => nil, :scraped_at => nil, :limit => CHUNK_SIZE ).each do |expanded_url|
    track_count :urls, 100
    src_url = expanded_url.short_url
    # next if src_url =~ %r{http://tiny\.cc/} # this one are all screwed up: timeouts
    src_url = repair_url(src_url)
    #
    begin
      # look for the redirect
      expanded_url.dest_url = Net::HTTP.get_response(URI.parse(src_url))["location"]
      # well formed if exists and matches the regexp
      expanded_url.well_formed = !!( expanded_url.dest_url && (expanded_url.dest_url =~ %r{\A#{RE_URL}\z}) )
    rescue Exception => e
      nil
    end
    expanded_url.scraped_at = Time.now
    expanded_url.save
    sleep 0.1 #throttle
  end
end

# chunks =  ExpandedUrl.count( :dest_url => nil ) / CHUNK_SIZE
# (0..chunks).each do |chunk|
#   ExpandedUrl.all( :dest_url => nil, :limit => CHUNK_SIZE, :offset => chunk*CHUNK_SIZE ).each do |expanded_url|
#     next if (expanded_url.short_url) =~ %r{\A#{RE_URL}\z}
#     # Find the sub-match
#     m = RE_URL.match(expanded_url.short_url) or next
#     new_url = m.captures.first
#     # puts "%-87s\t=> %s" %[expanded_url.short_url, new_url]
#     expanded_url.short_url = new_url
#     if ExpandedUrl.first(:short_url => expanded_url.short_url)
#       expanded_url.destroy
#     else
#       expanded_url.save
#     end
#   end
# end

#
# To prime table with urls from tweet_urls:
#
# INSERT IGNORE INTO `imw_twitter_graph`.`expanded_urls` (`short_url`)
# SELECT tweet_url AS short_url FROM `imw_twitter_graph`.tweet_urls
#   WHERE tweet_url LIKE 'http://tinyurl.com/_%'
#    OR   tweet_url LIKE 'http://is.gd/_%'
#    OR   tweet_url LIKE 'http://snipurl.com/_%'
#    OR   tweet_url LIKE 'http://snurl.com/_%'
#    OR   tweet_url LIKE 'http://bit.ly/_%'
#    OR   tweet_url LIKE 'http://ping.fm/_%'
#    OR   tweet_url LIKE 'http://tr.im/_%'
#    OR   tweet_url LIKE 'http://tiny.cc/_%'
#    OR   tweet_url LIKE 'http://urlenco.de/_%'
#    OR   tweet_url LIKE 'http://url.ie/_%'
#  ;
# To make a static list of short_urls to query:
#
# SELECT short_url
#   FROM expanded_urls WHERE dest_url IS NULL AND scraped_at IS NULL
#   INTO OUTFILE '~/ics/pool/social/network/twitter_friends/fixd/dump/tweet_url_shorteneds-20081214.tsv'
# ;
#
# -- DELETE FROM expanded_urls WHERE (LENGTH(dest_url) < 14)  OR (dest_url NOT LIKE 'htt%://_%._%')
#
#
# SELECT COUNT(*) as num, SUBSTR(SUBSTRING_INDEX(tweet_url, '/', 3),8) AS stub
#  from tweet_urls
# WHERE locate("/", tweet_url, 10) > 0
# GROUP BY stub
# ORDER BY num DESC
# LIMIT 100


# INSERT IGNORE INTO `imw_twitter_graph`.`expanded_urls` (`short_url`)
# SELECT tweet_url AS short_url FROM `imw_twitter_graph`.tweet_urls



# TINY_URLISHES_RE = %r{\Ahttp://(tinyurl\.com|is\.gd|snipurl\.com|snurl\.com|bit\.ly|ping\.fm|tr\.im|tiny\.cc|urlenco\.de|url\.ie)/[0-9a-zA-Z_\-]+}i
# if (expanded_url.short_url =~ TINY_URLISHES_RE) && (expanded_url.short_url.length <= 40)
# else
#   warn "funked up URL #{expanded_url.short_url}"
# end
# File.open('fixd/dump/tweet_url_shorteneds-20081206.tsv').each do |short_url|
#   short_url.chomp!
