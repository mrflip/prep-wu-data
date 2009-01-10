module TwitterFriends::StructModel
  Tweet.class_eval do
    include ModelCommon
    include TwitterFriends::TwitterRdf
    def rdf_resource
      @rdf_resource ||= rdf_component(id, :tweet)
    end

    #
    # Besides the
    #
    def to_rdf3_tuples
      tuples = super
      if (! in_reply_to_user_id.blank?)
        # Replied-to relationship
        #   remove this once ARepliesB generation works
        #   we append the status_id as a comment; can extract for reification.
        tuples << [
          rdf_component(twitter_user_id, :user), rdf_pred(:replied_to),       rdf_component(in_reply_to_user_id, :user),
          rdf_component(id, :tweet) ]
        # Thread relationship
        tuples << [
          rdf_component(id, :tweet),             rdf_pred(:continues_thread), rdf_component(in_reply_to_status_id, :user) ]
      end
      tuples
    end
  end
end
