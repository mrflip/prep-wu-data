module TwitterFriends
  module JsonModel

    # ===========================================================================
    #
    # Public timeline is an array of tweets => users
    #
    #
    class PublicTimelineParser < GenericJsonParser
      attr_accessor :scraped_at
      def initialize raw, scraped_at
        super raw
        self.scraped_at = scraped_at
      end

      # Public timeline is an array of users with one tweet each
      def healthy?() raw && raw.is_a?(Array) end
      def each &block
        raw.each do |hsh|
          parsed = JsonTweet.new(hsh, nil)
          next unless parsed && parsed.healthy?
          twitter_user = parsed.generate_user_partial
          tweet        = parsed.generate_tweet
          yield twitter_user, tweet
        end
      end
    end
  end
end
