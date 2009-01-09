module TwitterFriends::StructModel
  module TwitterUserCommon
    include TwitterRdf
    def key
      [id, scraped_at].join('-')
    end
    def keyspace_spread_resource_name
      "%s-%s" % [ self.resource_name, self.id.to_s[-2..-1] ]
    end
    def rdf_resource
      @rdf_resource ||= rdf_component(id, :user)
    end
  end
end
