require 'twitter_friends/twitter_model_common'
require 'hadoop/extensions/string'
require 'twitter_friends/twitter_rdf'
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
  MEMBERS_TYPES = {
    :created_at         => :date,
    :scraped_at         => :date,
    :screen_name        => :safetext,
    :protected          => :bool,
    :followers_count    => :int,
    :friends_count      => :int,
    :statuses_count     => :int,
    :favourites_count   => :int,
    :name               => :enctext,
    :url                => :enctext,
    :location           => :enctext,
    :description        => :enctext,
    :time_zone          => :safetext,
    :utc_offset         => :int,
    # :profile_background_color      => :safetext,
    # :profile_text_color            => :safetext,
    # :profile_link_color            => :safetext,
    # :profile_sidebar_border_color  => :safetext,
    # :profile_sidebar_fill_color    => :safetext,
    # :profile_background_tile       => :bool,
    # :profile_background_image_url  => :safetext,
    # :profile_image_url             => :safetext,
  }
  def members_with_types
    @members_with_types ||= MEMBERS_TYPES.slice(*members.map(&:to_sym))
  end
  MUTABLE_ATTRS = [
    :followers_count, :friends_count, :statuses_count, :favourites_count,
    :name, :url, :location, :description, :time_zone, :utc_offset,
    :profile_background_color, :profile_text_color, :profile_link_color, :profile_sidebar_border_color, :profile_sidebar_fill_color, :profile_background_tile, :profile_background_image_url, :profile_image_url
    ].to_set
  def mutable?(attr)
    MUTABLE_ATTRS.include?(attr)
  end
end

class TwitterUser        < Struct.new(
    :id, :scraped_at,
    :screen_name, :protected,
    :followers_count, :friends_count, :statuses_count, :favourites_count,
    :created_at )
  include TwitterModelCommon
  include TwitterUserCommon
end

class TwitterUserProfile < Struct.new(
    :id, :scraped_at,
    :name, :url, :location, :description,
    :time_zone, :utc_offset )
  include TwitterModelCommon
  include TwitterUserCommon
end


class TwitterUserStyle   < Struct.new(
    :id, :scraped_at,
    :profile_background_color,
    :profile_text_color,           :profile_link_color,
    :profile_sidebar_border_color, :profile_sidebar_fill_color,
    :profile_background_tile,      :profile_background_image_url,
    :profile_image_url )
  include TwitterModelCommon
  include TwitterUserCommon
end


class TwitterUserPartial < Struct.new(
    :id, :scraped_at,
    :screen_name, :protected, :followers_count, # appear in TwitterUser
    :name, :url, :location, :description,       # appear in TwitterUserProfile
    :profile_image_url )                        # appear in TwitterUserStyle
  include TwitterModelCommon
  include TwitterUserCommon
end

class TwitterUserId      < Struct.new(
    :id, :screen_name )
  include TwitterModelCommon
  include TwitterUserCommon
  def to_tsv
    self.to_a.join("\t")
  end
end
