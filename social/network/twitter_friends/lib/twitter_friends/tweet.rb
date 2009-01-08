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

end




