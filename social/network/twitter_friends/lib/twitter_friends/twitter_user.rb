require 'twitter_user/twitter_model_common'
require 'hadoop/extensions/string'
module TwitterUserCommon
  def resource_name()
    super() + '-' + self.screen_name[0..0].downcase ; end ; end
end


class TwitterUser < Struct.new(
    :id, :scraped_at,
    :screen_name, :protected,
    :followers_count, :friends_count, :statuses_count, :favourites_count,
    :created_at )
  include TwitterModelCommon
end

class TwitterUserProfile  = HadoopStruct.new(
    :id, :scraped_at,
    :name, :url, :location, :description,
    :time_zone, :utc_offset )
  include TwitterModelCommon
end


class TwitterUserStyle    = HadoopStruct.new(
    :id, :scraped_at,
    :profile_background_color,
    :profile_text_color,           :profile_link_color,
    :profile_sidebar_border_color, :profile_sidebar_fill_color,
    :profile_background_tile,      :profile_background_image_url,
    :profile_image_url )
  include TwitterModelCommon
end

class TwitterUserPartial  < Struct.new(
    :id, :scraped_at,
    :screen_name, :protected, :followers_count, # appear in TwitterUser
    :name, :url, :location, :description,       # appear in TwitterUserProfile
    :profile_image_url )                        # appear in TwitterUserStyle
  include TwitterModelCommon
end

