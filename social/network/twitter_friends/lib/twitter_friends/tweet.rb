require 'twitter_friends/twitter_model_common'

# require 'imw' ; include IMW
# require 'imw/transform'


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
  def key()
    id.to_s
  end

end




