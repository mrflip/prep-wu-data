#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'

# ./raw_requests_metadata.rb --rm --run "s3n://monkeyshines.infochimps.org/data/ripd/com.tw/com.twitter/20*/*,s3n://monkeyshines.infochimps.org/data/ripd/com.tw/com.twitter.search/20*/*" "/data/rawd/social/network/twitter/scrape_stats/requests_metadata/raw_requests_metadata"

# ./raw_requests_metadata.rb --rm --run  s3n://monkeyshines.infochimps.org/data/ripd/com.tw/com.twitter/20090118/com.twitter+20090118060110-0-old.tsv.bz2,s3n://monkeyshines.infochimps.org/data/ripd/com.tw/com.twitter/20090717/com.twitter+20090717210436-0-old.tsv.bz2,s3n://monkeyshines.infochimps.org/data/ripd/com.tw/com.twitter/20090930/comtwitter+20090930032850-23230.tsv.bz2,s3n://monkeyshines.infochimps.org/data/ripd/com.tw/com.twitter/20091102/comtwitter+20091102101522-16271.tsv.bz2,s3n://monkeyshines.infochimps.org/data/ripd/com.tw/com.twitter.search/20090930/comtwittersearch+20090930000702-19383.tsv.bz2,s3n://monkeyshines.infochimps.org/data/ripd/com.tw/com.twitter.search/20090717/com.twitter.search+20090717180542-75694.tsv.bz2 /tmp/sample_req_metadata


# Twitter API requests on and before 200907*:
#   user_timeline           3               0001554031      3       mrflip  http://twitter.com/statuses/user_timeline/0001554031.json?page=3&count=200      20090118043551  200     OK      [{"text":"status: Flip Join the Bo Duke army: http:\/\/urlkiss.com
# Twitter API requests after 200908*:
#   twitter_user_request    25117369        1               http://twitter.com/users/show/25117369.json     20090801012103  200     OK      {"following":false,"
#
# Twitter API requests in 200911 seem to have -xxxx on rsrc part
#
# Twitter search requests on and before 200908* :
#   twitter_search_request  http://search.twitter.com/search.json?q=night&rpp=100&max_id=3279499750 20090813034304  200     OK      {"results":[{"text":"Discussing
# Twitter search requests on and after 200909* :
#   twitter_search_request-http     http    1        {}     http://search.twitter.com/search.json?q=http&rpp=100    20090929232555  200     OK      {"results":[{"profile

class RawRequestsMetadataMapper < Wukong::Streamer::RecordStreamer
  def process rsrc=nil, *args
    return unless rsrc
    rsrc.gsub!(/-.*/, '')
    case
    when rsrc == 'twitter_search_request' && args[0] =~ %r{^http://search\.twitter\.com/search\.json\?q=(.+)&rpp}
      request_id = $1
      scraped_at = args[1]
      response   = args[2]
    when args[4] =~ %r{^http://twitter\.com/}
      pri, request_id, page, moreinfo, url, scraped_at, response, *_ = args
    else
      request_id,      page, moreinfo, url, scraped_at, response, *_ = args
    end
    request_id = request_id.to_i if (request_id =~ /^[0-9]+$/)
    yield [rsrc, request_id, page, scraped_at, response]
  end
end

#
# Executes the script
#
Wukong::Script.new(
  RawRequestsMetadataMapper,
  nil).run

