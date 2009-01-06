require 'twitter_model_common'

# require 'imw' ; include IMW
# require 'imw/transform'

class Tweet < Struct.new(
    :id,  :created_at,
    :twitter_user_id, :text, :favorited, :truncated, :tweet_len,
    :in_reply_to_user_id, :in_reply_to_status_id, :fromsource, :fromsource_url )
  include TwitterModelCommon

end



# ===========================================================================
#
# Transform tweet
#
ATSIGNS_TRANSFORMER   = RegexpRepeatedTransformer.new('text', RE_ATSIGNS)
HASHTAGS_TRANSFORMER  = RegexpRepeatedTransformer.new('text', RE_HASHTAGS)
TWEETURLS_TRANSFORMER = RegexpRepeatedTransformer.new('text', RE_URL)
def emit_tweet tweet_hsh
  #
  scrub tweet_hsh, :text

  tweet_hsh['favorited']  = tweet_hsh['favorited'] ? 1 : 0
  tweet_hsh['truncated']  = tweet_hsh['truncated'] ? 1 : 0
  tweet_hsh['tweet_len']  = tweet_hsh['text'].length
  #
  # Emit
  #
  repair_date_attr(tweet_hsh, 'created_at')
  scraped_at      = tweet_hsh['created_at']     # Tweets are immutable
  status_id       = tweet_hsh['id']
  twitter_user    = tweet_hsh['twitter_user']
  twitter_user_id = tweet_hsh['twitter_user_id']
  owner_id        = twitter_user                # emit using twitter_user as key so all group together.
  #
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

# {
#   "favorited"                    : false,
#   "in_reply_to_user_id"          : null,
#   "created_at"                   : "Wed Nov 19 07:16:58 +0000 2008",
#   "in_reply_to_status_id"        : null,
#   "truncated"                    : false,
#   "id"                           : 1012519767,
#   "source"                       : "web",
#   "text"                         : "[Our lander (RIP) had the best name. The next rover to Mars, @MarsScienceLab, needs a name. A contest for kids: http:\/\/is.gd\/85rQ  ]"
# }


