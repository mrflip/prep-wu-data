# ===========================================================================
#
# Twitter accepts URLs somewhat idiosyncratically, probably for good reason --
# we rarely see ()![] in urls; more likely in a status they are punctuation.
#
# This is what I've reverse engineered.
#
#
# Notes:
#
# * is.gd uses a trailing '-' (to indicate 'preview mode'): clever.
# * pastoid.com uses a trailing '+', and idek.net a trailing ~ for no reason. annoying.
# * http://www.5irecipe.cn/recipe_content/2307/'/
#
# http://www.facebook.com/groups.php?id=1347199977&gv=12#/group.php?gid=18183539495
#
RE_DOMAIN_HEAD     = '(?:[a-zA-Z0-9\-]+\.)+'
RE_DOMAIN_TLD      = '(?:com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum|[a-zA-Z]{2})'
RE_URL_SCHEME      = '[a-zA-Z][a-zA-Z0-9\-\+\.]+'
RE_URL_UNRESERVED  = 'a-zA-Z0-9'   + '\-\._~'
RE_URL_OKCHARS     = RE_URL_UNRESERVED + '\'\+\,\;=' + '/%:@'   # not !$&()* [] \|
RE_URL_QUERYCHARS  = RE_URL_OKCHARS    + '&='
RE_URL_HOSTPART    = "#{RE_URL_SCHEME}://#{RE_DOMAIN_HEAD}#{RE_DOMAIN_TLD}"
RE_URL             = %r{(
              #{RE_URL_HOSTPART}                   # Host
  (?:(?: \/ [#{RE_URL_OKCHARS}]+?          )*?   # path:  / delimited path segments
     (?: \/ [#{RE_URL_OKCHARS}]*[\w\-\+\~] )     #        where the last one ends in a non-punctuation.
     |                                             #        ... or no path segment
                                             )\/?  #        with an optional trailing slash
     (?: \? [#{RE_URL_QUERYCHARS}]+  )?           # query: introduced by a ?, with &foo= delimited segments
     (?: \# [#{RE_URL_OKCHARS}]+     )?           # frag:  introduced by a #
)}x


# ===========================================================================
#
# A hash following a non-alphanum_ (or at the start of the line
# followed by (any number of alpha, num, -_.+:=) and ending in an alphanum_
#
# This is overly generous to those dorky triple tags (geo:lat=69.3), but we'll soldier on somehow.
#
RE_HASHTAGS        = %r{(?:^|\W)\#([a-zA-Z0-9\-_\.+:=]+\w)(?:\W|$)}

# ===========================================================================
#
# following either the start of the line, or a non-alphanum_ character
# the string of following [a-zA-Z0-9_]
#
RE_ATSIGNS         = %r{(?:^|\W)@(\w+)}

# ===========================================================================
#
# following either the start of the line, or a non-alphanum_ character
# the string of following [a-zA-Z0-9_]
#
# Cheating a little with the [\s:\-]* (allows RT:: ::-:@foo)
RE_RETWEET        = %r{\b(RT|retweet|via|retweeting)[\s:\-]*@(\w+)}i
RE_PLEASE         = %r{(please|plz)}

# ===========================================================================
#


class TweetExtract

  def tweet_len
    #   tweet_hsh['tweet_len']  = tweet_hsh['text'].length
  end

  def atsigns
  end

  def hashtags
  end

  def tweet_urls
  end

  def retweets
  end

# ATSIGNS_TRANSFORMER   = RegexpRepeatedTransformer.new('text', RE_ATSIGNS)
# HASHTAGS_TRANSFORMER  = RegexpRepeatedTransformer.new('text', RE_HASHTAGS)
# TWEETURLS_TRANSFORMER = RegexpRepeatedTransformer.new('text', RE_URL)
def emit_tweet tweet_hsh
  if tweet_hsh['in_reply_to_user_id'] then
    at                    = repair_id(tweet_hsh, 'in_reply_to_user_id')
    in_reply_to_status_id = repair_id(tweet_hsh, 'in_reply_to_status_id')
    reply    = ARepliedB.new_from_hash( scraped_at, 'user_a_id' => twitter_user_id, 'user_b_id'   => at, 'status_id' => status_id, 'in_reply_to_status_id' => in_reply_to_status_id).emit
  end
  ATSIGNS_TRANSFORMER.transform(  tweet_hsh).each do |at|
    atsign    = AAtsignsB.new_from_hash(scraped_at, 'user_a_id' => twitter_user_id, 'user_b_name'  => at, 'user_a_name' => twitter_user, 'status_id' => status_id).emit
  end
  TWEETURLS_TRANSFORMER.transform(tweet_hsh).each do |at|
    tweet_url = TweetUrl.new_from_hash( scraped_at, 'user_a_id' => twitter_user_id, 'tweet_url'   => at, 'status_id' => status_id).emit
  end
  HASHTAGS_TRANSFORMER.transform( tweet_hsh).each do |at|
    hashtag   = Hashtag.new_from_hash(  scraped_at, 'user_a_id' => twitter_user_id, 'hashtag'     => at, 'status_id' => status_id).emit
  end
  Tweet.new_from_hash(scraped_at, tweet_hsh).emit
end

end
