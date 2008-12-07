#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'json'
require 'faster_csv'
require 'imw' ; include IMW
require 'imw/transform'
require 'twitter_autourl'
require 'hadoop_utils'; include HadoopUtils
# as_dset __FILE__

DATEFORMAT = "%Y%m%d%H%M%S"
TwitterUserPartial  = HadoopStruct.new( '01',  :id,  :screen_name, :followers_count, :protected, :name, :url, :location, :description, :profile_image_url )
TwitterUser         = HadoopStruct.new( '02',  :id,  :screen_name, :created_at, :statuses_count, :followers_count, :friends_count, :favourites_count, :protected )
TwitterUserProfile  = HadoopStruct.new( '03',  :id,  :name, :url, :location, :description, :time_zone, :utc_offset )
TwitterUserStyle    = HadoopStruct.new( '04',  :id,  :profile_background_color, :profile_text_color, :profile_link_color, :profile_sidebar_border_color, :profile_sidebar_fill_color, :profile_background_image_url, :profile_image_url, :profile_background_tile )
AFollowsB           = HadoopStruct.new( '05',  :user_a_id, :user_a, :user_b )
BFollowsA           = HadoopStruct.new( '06',  :user_a_id, :user_a, :user_b )
ARepliedB           = HadoopStruct.new( '07',  :user_a_id, :user_b_id,       :status_id, :in_reply_to_status_id )
AAtsignsB           = HadoopStruct.new( '08',  :user_a_id, :user_a, :user_b, :status_id )
Hashtag             = HadoopStruct.new( '09',  :user_a_id, :hashtag,         :status_id )
TweetUrl            = HadoopStruct.new( '10',  :user_a_id, :tweet_url,       :status_id )
Tweet               = HadoopStruct.new( '11', :id,  :created_at, :twitter_user_id, :text, :favorited, :truncated, :tweet_len, :in_reply_to_user_id, :in_reply_to_status_id, :fromsource, :fromsource_url, :all_atsigns, :all_hash_tags, :all_tweeted_urls )
# UserMetric   = HadoopStruct.new( :id,  :replied_to_count, :tweeturls_count, :hashtags_count, :prestige, :pagerank, :twoosh_count )

# transform and emit User
#
def emit_user hsh, timestamp, is_partial
  hsh['protected']  = hsh['protected'] ? 1 : 0
  hsh['created_at']  = DateTime.parse(hsh['created_at']).strftime(DATEFORMAT) if hsh['created_at']
  scrub hsh, :name, :location, :description, :url
  if is_partial
    TwitterUserPartial.new(timestamp, hsh).emit( hsh['screen_name'] )
  else
    TwitterUser.new(timestamp, hsh).emit( hsh['screen_name'] )
    TwitterUserProfile.new(timestamp, hsh).emit( hsh['screen_name'] )
    TwitterUserStyle.new(timestamp, hsh).emit( hsh['screen_name'] )
  end
end


# ===========================================================================
#
# Transform tweet
#

ATSIGNS_TRANSFORMER   = RegexpRepeatedTransformer.new('text', RE_ATSIGNS)
HASHTAGS_TRANSFORMER  = RegexpRepeatedTransformer.new('text', RE_HASHTAGS)
TWEETURLS_TRANSFORMER = RegexpRepeatedTransformer.new('text', RE_URL)
def emit_tweet tweet_hsh, timestamp
  #
  scrub tweet_hsh, :text
  fromsource_raw = tweet_hsh['source']
  if ! fromsource_raw.blank?
    if m = %r{<a href="([^\"]+)">([^<]+)</a>}.match(fromsource_raw)
      tweet_hsh['fromsource_url'], tweet_hsh['fromsource'] = m.captures
    else
      tweet_hsh['fromsource'] = fromsource_raw
    end
  end
  tweet_hsh['created_at']  = DateTime.parse(tweet_hsh['created_at']).strftime(DATEFORMAT) if tweet_hsh['created_at']
  tweet_hsh['favorited'] = tweet_hsh['favorited'] ? 1 : 0
  tweet_hsh['truncated'] = tweet_hsh['truncated'] ? 1 : 0
  tweet_hsh['tweet_len'] = tweet_hsh['text'].length
  #
  # Emit
  #
  timestamp       = tweet_hsh['created_at']     # Tweets are immutable
  status_id       = tweet_hsh['id']
  twitter_user    = tweet_hsh['twitter_user']
  twitter_user_id = tweet_hsh['twitter_user_id']
  owner_id        = twitter_user                # emit using twitter_user as key so all group together.
  #
  if tweet_hsh['in_reply_to_user_id'] then
    at = "%012d"%tweet_hsh['in_reply_to_user_id']
    in_reply_to_status_id = "%012d"%tweet_hsh['in_reply_to_status_id']
    reply = ARepliedB.new timestamp, 'id' => twitter_user_id,
      'user_a_id' => twitter_user_id, 'user_b' => at,
      'status_id' => status_id, 'in_reply_to_status_id' => in_reply_to_status_id
    reply.emit(twitter_user)
  end
  all_atsigns = ATSIGNS_TRANSFORMER.transform(  tweet_hsh)
  tweet_hsh['all_atsigns'] =  all_atsigns.to_json
  all_atsigns.each do |at|
    atsign = AAtsignsB.new timestamp, 'user_a_id' => twitter_user_id, 'user_a' => twitter_user,
      'user_b'  => at, 'status_id' => status_id
    atsign.emit at
  end
  all_tweeted_urls = TWEETURLS_TRANSFORMER.transform(tweet_hsh)
  tweet_hsh['all_tweeted_urls'] = all_tweeted_urls.to_json
  all_tweeted_urls.each do |at|
    tweet_url = TweetUrl.new timestamp, 'user_a_id' => twitter_user_id, 'tweet_url' => at, 'status_id' => status_id
    tweet_url.emit owner_id
  end
  all_hash_tags = HASHTAGS_TRANSFORMER.transform( tweet_hsh)
  tweet_hsh['all_hash_tags'] = all_hash_tags.to_json
  all_hash_tags.each do |at|
    hashtag = Hashtag.new timestamp,  'user_a_id' => twitter_user_id, 'hashtag' => at, 'status_id' => status_id
    hashtag.emit owner_id
  end
  Tweet.new(timestamp, tweet_hsh).emit owner_id
end


#
#
def load_line line
  m = %r{^(\w+)-(\w+)-(\d+)-(\d{14})\t(.*)$}.match(line)
  if !m then warn "Can't grok #{line}"; return [] ; end
  resource, screen_name, page, timestamp, json = m.captures
  begin
    raw = JSON.load(json)
  rescue Exception => e
    warn "Couldn't open and parse #{[resource, screen_name, page, timestamp].join('-')}: #{e}"
    return []
  end
  origin = [resource, screen_name, page, timestamp].join('-')
  [ resource, screen_name, page, origin, timestamp, raw ]
end


#
# The issue -- when we get a followers page, we know the
# screen name but not the native ID.
#
# So we have to emit a 'BFollowsA', clean it up in the reduce stage, and then be
# stuck with an indeterminate (but harmless) # of duplicate a->b follower links
#

# ===========================================================================
#
# parse each line in STDIN
#
$stdin.each do |line|
  line.chomp! ; next if line.blank?
  resource, screen_name, page, origin, timestamp, raw = load_line(line); next if raw.blank?
  track_count screen_name[0..1].downcase, 100
  # $stderr.puts("parsing %-15s\t%-31s\t%7d\t%s" % [resource, screen_name, page, timestamp])
  case resource
  when 'raw_followers', 'raw_friends'
    raw.each do |hsh|
      next if hsh.blank? || (! hsh.is_a?(Hash))
      hsh['id'] = "%012d"%hsh['id'].to_i if hsh['id']
      #
      # user
      emit_user hsh, timestamp, true
      #
      # follower or friend
      if resource == 'raw_followers'
        # follower: this person *follows* the file owner
        AFollowsB.new(timestamp,
          'user_a' => hsh['screen_name'], 'user_a_id' => hsh['id'],
          'user_b' => screen_name).emit(screen_name)
      else
        # friend: this person is *followed by* the file owner.
        BFollowsA.new(timestamp,
          'user_a' => hsh['screen_name'], 'user_a_id' => hsh['id'],
          'user_b' => screen_name).emit(screen_name)
      end
      #
      # tweet
      tweet_hsh  = hsh['status'] or next
      tweet_hsh['twitter_user'   ] = hsh['screen_name']
      tweet_hsh['twitter_user_id'] = "%012d"%hsh['id'].to_i
      tweet_hsh['id']              = "%012d"%tweet_hsh['id'].to_i
      emit_tweet tweet_hsh, timestamp
    end
  when 'raw_userinfo'
    raw['id'] = "%012d"%raw['id'].to_i if raw['id']
    emit_user raw, timestamp, false
  else
    raise "Crap bubbles -- unexpected resource #{resource}"
  end
end

# ===========================================================================
#
# afollowsb     time  1 0 0 0 0 0 0   user_a_id       user_b_id
# afavoredb     time  0 1 0 0 0 0 0   user_a_id       user_b_id
# arepliedb     time  0 0 1 0 0 0 0   user_a_id       user_b_id       status_id
# aatsigndb     time  0 0 0 1 0 0 0   user_a_id       user_b_id       status_id
#
# hashtag       time  0 0 0 0 1 0 0   user_a_id                       status_id       sha1(hashtag)
# url           time  0 0 0 0 0 1 0   user_a_id                       status_id       sha1(url)
# word          time  0 0 0 0 0 0 1   user_a_id                                       sha1(word)






#
# scrape_user_info        00
# scrape_user_info        0000FF
# scrape_user_info        000FF
#
# 16
# user            000000000012    jack    20060321205014  2597    12497   357     0       20081130010028
# user            000000000013    biz     20060321205143  2942    22940   174     0       20081130010023
# user            000000000013    biz     20060321205143  2948    23084   172     0       20081201164451
#
# user_profile    000000000012    Jack Dorsey     http://gu.st/   SF      A sailor, a tailor.     Pacific Time (US & Canada)      -28800  20081130010028
# user_profile    000000000013    Biz Stone       http://www.bizstone.com Berkeley, CA    Co-founder of Twitter   Pacific Time (US & Canada)      -28800  20081130010023
# user_profile    000000000014    noah    http://www.noahglass.com        San Francisco   i started this  Pacific Time (US & Canada)      -28800  20081130010143
#
# user_partial    000000000012    jack    12319   0       Jack Dorsey     http://gu.st/   SF      A sailor, a tailor.     http://s3.amazonaws.com/twitter_production/profile_images/54668082/Picture_2_normal.png 20081126072324
# user_partial    000000000012    jack    12355   0       Jack Dorsey     http://gu.st/   SF      A sailor, a tailor.     http://s3.amazonaws.com/twitter_production/profile_images/54668082/Picture_2_normal.png 20081126180920
# user_partial    000000000012    jack    12369   0       Jack Dorsey     http://gu.st/   SF      A sailor, a tailor.     http://s3.amazonaws.com/twitter_production/profile_images/54668082/Picture_2_normal.png 20081126231618
#
# user_style      000000000012    8B542B  333333  9D582E  D9B17E  EADEAA          http://s3.amazonaws.com/twitter_production/profile_images/54668082/Picture_2_normal.png         20081130010028
# user_style      000000000013    352726  3E4415  D02B55  829D5E  99CC33          http://s3.amazonaws.com/twitter_production/profile_images/58660087/biz_stone_normal.png         20081130010023
# user_style      000000000014    ba030f  6f726e  b62b3a  f62c47  e1dfe0  http://s3.amazonaws.com/twitter_production/profile_background_images/2/flowers-and-logo.jpg     http://s3.amazonaws.com/twitter_production/profile_images/14019402/noahglass_normal.jpg         false   20081130010143
#
# b_follows_a     0               000000000012    BigEd   jack    20081129045352
# b_follows_a     0               000000000012    niall   jack    20081126154850
# b_follows_a     0               000000000013    cw      biz     20081126232155
#
# 9
# a_follows_b     0               000000000012    Aloisius        jack    20081204013142
# a_follows_b     0               000000000012    BSbikeNJ        jack    20081201194251
# a_follows_b     0               000000000012    Benoit  jack    20081129143009
#
# 12
# a_atsigns_b     000000000013    0               biz     Livia   20081129204944
# a_atsigns_b     000000000013    000000000291    biz     goldman 20081204054833
# a_atsigns_b     000000000013    000000000586    biz     sacca   20081127034711
#
# a_replied_b     000000000013    001031611945    1031480806      20081201030031
# a_replied_b     000000000015    001031508955    1031474576      20081201013828
# a_replied_b     000000000015    001032879471    1032873074      20081201202032
#
# tweet_url       000000000013    http://bit.ly/bk8n      001028336212    20081128185751
# tweet_url       000000000013    http://bit.ly/oWRL      001037006869    20081203220933
# tweet_url       000000000013    http://flickr.com/photos/biz/3065208030/        001027426700    20081128042836
#
# 7
#
# hashtag         000000000057    Mumbai  001027471935    20081128051616
# hashtag         000000000414    zataomm 001026787380    20081127184620
# hashtag         000000000506    DiMAS2008       001027608362    20081128080122
#
# 42
#
# tweet           000000003212    20060501005920  000000000211    just setting up my twttr        0       0       24                      web             []      []      []      20060501005920
# tweet           000000003213    20060501010016  000000000212    just setting up my twttr        0       0       24                      web             []      []      []      20060501010016
# tweet           000000003219    20060501010812  000000000218    just setting up my twttr        0       0       24                      web             []      []      []      20060501010812

