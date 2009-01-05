require 'twitter_friends/twitter_model_common'
require 'hadoop/extensions/string'
module TwitterUserCommon
end

class TwitterUser        < Struct.new(
    :id, :scraped_at,
    :screen_name, :protected,
    :followers_count, :friends_count, :statuses_count, :favourites_count,
    :created_at )
  include TwitterModelCommon
end

class TwitterUserProfile < Struct.new(
    :id, :scraped_at,
    :name, :url, :location, :description,
    :time_zone, :utc_offset )
  include TwitterModelCommon
end


class TwitterUserStyle   < Struct.new(
    :id, :scraped_at,
    :profile_background_color,
    :profile_text_color,           :profile_link_color,
    :profile_sidebar_border_color, :profile_sidebar_fill_color,
    :profile_background_tile,      :profile_background_image_url,
    :profile_image_url )
  include TwitterModelCommon
end


class TwitterUserPartial < Struct.new(
    :id, :scraped_at,
    :screen_name, :protected, :followers_count, # appear in TwitterUser
    :name, :url, :location, :description,       # appear in TwitterUserProfile
    :profile_image_url )                        # appear in TwitterUserStyle
  include TwitterModelCommon
end

class TwitterUserId      < Struct.new(
    :id, :screen_name )
  include TwitterModelCommon
  def to_tsv
    self.to_a.join("\t")
  end
end
