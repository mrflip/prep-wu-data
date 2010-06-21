#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'wuclan/twitter';
require 'wuclan/twitter/parse';
require 'wuclan/twitter/scrape'; include Wuclan::Twitter::Scrape

#
# Twitter stream requests
#
#   http://apiwiki.twitter.com/Streaming-API-Documentation
#
# Fills a file with JSON status records, one line per status.
#
#   {"text":"Hey #bigdata #hadoop geeks: who's missing? @mrflip/bigdata / http://bit.ly/datatweeps","favorited":false,"geo":null,"in_reply_to_screen_name":null,"source":"web","created_at":"Thu Oct 29 09:29:32 +0000 2009","user":{"verified":false,"notifications":null,"profile_text_color":"000000","time_zone":"Central Time (US & Canada)","following":null,"profile_link_color":"0000ff","profile_image_url":"http://a3.twimg.com/profile_images/377919497/FlipCircle-2009-900-trans_normal.png","profile_background_image_url":"http://a3.twimg.com/profile_background_images/2348065/2005Mar-AustinTypeTour-075_-_Rappers_Delight_Raindrop.jpg","description":"Increasing access to free open data, building tools to Organize, Explore and Comprehend massive data sources - http://infochimps.org","location":"iPhone: 30.316122,-97.733817","profile_sidebar_fill_color":"ffffff","screen_name":"mrflip","profile_background_tile":false,"profile_sidebar_border_color":"f0edd8","statuses_count":1307,"followers_count":678,"protected":false,"url":"http://infochimps.org","created_at":"Mon Mar 19 21:08:24 +0000 2007","friends_count":514,"name":"Philip Flip Kromer","geo_enabled":false,"profile_background_color":"BCC0C8","id":1554031,"utc_offset":-21600,"favourites_count":61},"id":5254924802,"in_reply_to_user_id":null,"in_reply_to_status_id":null,"truncated":false}
#
# Try it with
#   twuserpass='name:pass'
#   curl -s -u $twpass http://stream.twitter.com/1/statuses/sample.json > /tmp/sample.json
#   cat /tmp/sample.json | parse_twitter_stream_requests.rb --map
#
class TwitterRequestParser < Wukong::Streamer::RecordStreamer

  def recordize *args
    [ TwitterStreamRequest.new(super(*args).first) ]
  end

  def process request, *args, &block
    request.parse(*args) do |obj|
      # next if obj.is_a? BadRecord
      yield obj
    end
  end
end

# This makes the script go.
Wukong::Script.new(TwitterRequestParser, nil).run
