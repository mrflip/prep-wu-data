module RelationshipCommon
  include TwitterRdf

  def key()
    [user_a_id, user_b_id].join('-')
  end

  def rdf_resource
    @rdf_resource ||= rdf_component(user_a_id, :user)
  end

  #
  # For efficient Map-Reducing
  #
  def keyspace_spread_resource_name()
    "%s-%s" % [ self.resource_name, self.user_a_id.to_s[-2..-1] ]
  end

end


class AFollowsB           < Struct.new( :user_a_id, :user_b_id  )
  include TwitterModelCommon
  include RelationshipCommon

  def to_rdf3_tuples
    [
      [rdf_component(user_b_id, :user), rdf_pred(:follows), rdf_component(user_b_id, :user)]
    ]
  end
end

class ARepliesB           < Struct.new( :user_a_id, :user_b_id, :status_id, :in_reply_to_status_id )
  include TwitterModelCommon
  include RelationshipCommon

  def to_rdf3_tuples
    [
      [rdf_component(user_b_id, :user), rdf_pred(:replied_to), rdf_component(user_b_id, :user), rdf_component(status_id, :tweet) ]
    ]
  end
end

# note we have no user_b_id for @foo
class AAtsignsB           < Struct.new( :user_a_id, :user_b_name, :status_id )
  include TwitterModelCommon
  include RelationshipCommon
  def key()
    [user_a_id, user_b_name]
  end

  def to_rdf3_tuples
    [
      [rdf_component(user_b_id, :user), rdf_pred(:atsigns), rdf_component(user_b_name, :user)]
    ]
  end
end


