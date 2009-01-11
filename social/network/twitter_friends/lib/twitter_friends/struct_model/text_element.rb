module TwitterFriends::StructModel

  #
  #
  #
  module TextElementCommon
    # Key on the user-user pair
    def key()
      [text, status_id].join('-')
    end
    def keyspace_spread_resource_name
      # To make sure there's something, grab last 2 of status_id as fallback
      slug = self.status_id.to_s[-2..-1]
      # use first two of text, but only alphanums
      slug = ( text.gsub(/\W+/, '') + slug )[0..1].downcase
      [self.resource_name, slug].join("-")
    end
  end

  #
  # Topical #hashtags extracted from tweet text
  #
  # the twitter_user_id is denormalized
  # but is often what we wnat: saves a join
  #
  class Hashtag < Struct.new( :hashtag,    :status_id, :twitter_user_id )
    include ModelCommon
    include TextElementCommon
    alias_method :text, :hashtag
  end

  class TweetUrl < Struct.new( :tweet_url, :status_id, :twitter_user_id )
    include ModelCommon
    include TextElementCommon
    alias_method :text, :tweet_url
  end
  
  #
  # A re-tweet is /sent/ by user_a, repeating an earlier message by user_b
  # Any tweet containing text roughly similar to 
  #   RT @user <stuff>
  # with equivalently for RT: retweet, via, retweeting 
  #
  #   !!! OR !!!
  #
  # A retweet whore request, something like
  #   pls RT Hey lookit me
  # 
  # We just pass along both in the same data structure; the heuristic is poor
  # enough that we leave it to later steps to be clever.  (Note retweets and
  # non-retweet-whore-requests have user_b_name set and unset respectively.)
  #
  # +user_a_id:+   the user who sent the re-tweet
  # +status_id:+   the id of the tweet *containing* the re-tweet (for the ID of the original tweet you're on your own.)
  # +user_b_name:+ the user citied as originating: RT @user_b_name 
  # +please_flag:+ a 1 if the text contains 'please' or 'plz' as a stand-alone word
  # +text:+        the *full* text of the tweet
  #
  class ARetweetsB <  Struct.new( :user_a_id, :status_id, :user_b_name, :please_flag, :text )
    include ModelCommon
    include TextElementCommon
    
    #
    # If there's no user we'll assume this
    # is a retweet and not an rtwhore.
    #
    def is_retweet?
      ! user_b_name.blank?
    end
    
    def initialize *args
      super *args
      self.please_flag = ModelCommon.unbooleanize(self.please_flag)
    end
    
    def key 
      status_id
    end
  end
end
