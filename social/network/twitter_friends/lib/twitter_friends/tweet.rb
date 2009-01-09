# -*- coding: utf-8 -*-
require 'twitter_friends/twitter_model_common'
require 'twitter_friends/twitter_rdf'

# ===========================================================================
#
# Tweet
#
# Text and metadata for a twitter status update
#
class Tweet < Struct.new(
    :id,  :created_at, :twitter_user_id,
    :favorited, :truncated,
    :in_reply_to_user_id, :in_reply_to_status_id,
    :text,
    :source )
  include TwitterModelCommon
  include TwitterRdf

  MEMBERS_TYPES = [
    [ :created_at            , :date     ],
    [ :twitter_user_id       , :user     ],
    [ :favorited             , :boolskip ],
    [ :truncated             , :boolskip ],
    [ :in_reply_to_user_id   , :user     ],
    [ :in_reply_to_status_id , :tweet    ],
    [ :text                  , :enctext  ],
    [ :source                , :enctext  ],
  ]
  def members_with_types
    @members_with_types ||= MEMBERS_TYPES
  end

  def key()
    id.to_s
  end

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




