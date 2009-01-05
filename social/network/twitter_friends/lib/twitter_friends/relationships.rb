class AFollowsB           = Struct.new(
    :user_a_id, :user_b_id  )
  include TwitterModelCommon
end

class ARepliesB           = Struct.new(
    :user_a_id, :user_b_id,
    :status_id, :in_reply_to_status_id )
  include TwitterModelCommon
end

# note we have no user_b_id for @foo
class AAtsignsB           = Struct.new(
    :user_a_id, :user_b_name,
    :status_id )
  include TwitterModelCommon
end
