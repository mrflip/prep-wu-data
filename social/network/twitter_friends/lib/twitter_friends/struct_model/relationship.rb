module TwitterFriends::StructModel
  # features common to all user-user relationships.
  module RelationshipCommon
    # For efficient Map-Reducing
    def keyspace_spread_resource_name()
      "%s-%s" % [ self.resource_name, self.user_a_id.to_s[-2..-1] ]
    end
  end

  # Follower/Friend relationship
  class AFollowsB           < Struct.new( :user_a_id, :user_b_id  )
    include ModelCommon
    include RelationshipCommon
    # Key on the user-user pair
    def key()
      [user_a_id, user_b_id].join('-')
    end
  end

  # Direct (threaded) replies: occur at the start of a tweet.
  class ARepliesB           < Struct.new( :user_a_id, :user_b_id, :status_id, :in_reply_to_status_id )
    include ModelCommon
    include RelationshipCommon
    # Key on the user-user-status pair
    def key()
      [user_a_id, user_b_id, status_id].join('-')
    end
  end

  # Atsign mentions anywhere in the tweet
  # note we have no user_b_id for @foo
  class AAtsignsB           < Struct.new( :user_a_id, :user_b_name, :status_id )
    include ModelCommon
    include RelationshipCommon
    # Key on the user-user-status pair
    def key()
      [user_a_id, user_b_id, status_id].join('-')
    end
  end
end
