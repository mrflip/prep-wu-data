
class Hashtag < Struct.new(
    :twitter_user_id, :hashtag,   :status_id )
  include TwitterModelCommon
end
