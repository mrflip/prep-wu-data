module TwitterFriends::StructModel

  class Hashtag < Struct.new( :twitter_user_id, :hashtag,   :status_id )
    include ModelCommon
  end
end
