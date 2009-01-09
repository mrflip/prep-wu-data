module TwitterFriends::StructModel

  class TweetUrl < Struct.new( :twitter_user_id, :tweet_url, :status_id )
    include ModelCommon
  end
end
