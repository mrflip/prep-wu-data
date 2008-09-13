
#
#
#
class DeliciousLink
  include DataMapper::Resource
  # Basic info
  property      :id,                    Integer,  :serial => true

  # becomes handle
  property      :link_url,              String,   :length => 1024, :nullable => false

  #
  # These are 'facts'
  # property      :delicious_id,          String,   :length => 32,   :nullable => false,          :unique_index => true
  # property      :num_delicious_savers,  Integer

  # name
  property      :title,                 String,   :length => 255

  #
  # ratings...
  # has n,        :socialites_links
  # has n,        :socialites,    :through => :socialites_links
end


# http://delicious.com/ferrisp
class Socialite
  # trustification
  # property   :following_count,       Integer
  # property   :followers_count,       Integer
  # property :toptags,               Text # serialized top 10 tags
end
