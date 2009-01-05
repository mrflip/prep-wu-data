#!/usr/bin/env ruby

class TweetUrl < Struct.new(
    :twitter_user_id, :tweet_url, :status_id )
  include TwitterModelCommon
end
