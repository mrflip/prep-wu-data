module TwitterFriends
  module JsonModel
    # ===========================================================================
    #
    # Friends or Followers is a flat list of users => tweets
    #
    #
    class FriendsFollowersParser < GenericJsonParser
      attr_accessor :scraped_at, :context, :owning_user_id
      def initialize raw, context, scraped_at, owning_user_id
        super raw
        self.context    = context
        self.scraped_at = scraped_at
        self.owning_user_id  = owning_user_id
      end

      # Extracted JSON should be an array
      def healthy?() raw && raw.is_a?(Array) end

      def generate_relationship user
        case context.to_sym
        when :followers then AFollowsB.new(user.id,        owning_user_id)
        when :friends   then AFollowsB.new(owning_user_id, user.id)
        else raise "Can't make a relationship out of #{context}: communication is the key."
        end
      end

      #
      # Enumerate over users (each having one tweet)
      #
      def each &block
        raw.each do |hsh|
          parsed = JsonTwitterUser.new(hsh, scraped_at)
          next unless parsed && parsed.healthy?
          user_b       = parsed.generate_user_partial
          tweet        = parsed.generate_tweet
          relationship = generate_relationship(user_b)
          yield user_b, tweet, relationship
        end
      end
    end

  end
end
