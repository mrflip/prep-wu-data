
class User
  include DataMapper::Resource
  # Basic info
  property      :id,                         Integer,           :serial => true
  property      :twitter_name,               String,            :nullable => false
  property      :file_date,                  DateTime
  property      :twitter_id,                 Integer

  #
  property      :following_count,            Integer
  property      :followers_count,            Integer
  property      :favorites_count,            Integer
  property      :updates_count,              Integer

  #
  property      :real_name,                  String
  property      :location,                   String
  property      :web,                        String
  property      :bio,                        Text

  # Page appearance
  property      :style_profile_img_url,      String
  property      :style_mini_img_url,         String
  property      :style_bg_img_url,           String
  property      :style_bg_img_tile,          Integer
  property      :style_link_color,           Integer
  property      :style_name_color,           Integer
  property      :style_text_color,           Integer
  property      :style_bg_color,             Integer
  property      :style_sidebar_fill_color,   Integer
  property      :style_sidebar_border_color, Integer

  # Status info on page
  property      :latest_update_time,         DateTime
  property      :pg1_first_update_time,      DateTime

  #
  # Associations
  #
  # has n,      :followers,               :through => Following, :child_key => :follower_id
  # has n,      :follows,                 :through => Following, :child_key => :follows_id
  #   :associated_class => 'User', :join_table => 'following', :right_foreign_key => follows_id
  # has n,      :statuses
end

#
# Following
#
class Following
  property       :follower_id
  property       :follows_id
end

#
#   #
#   # Status
#   #
# class Status
#   property      :twitter_status_id,          String
#   property      :posting_user,               String   # user
#   property      :datetime,                   DateTime
#   property      :fromsource,                 String
#   property      :inreplyto,                  String   # user
#   property      :text,                       Text
#   belongs_to    :user
#   # has n,        :users_atsigned
#   # has n,        :links
#   # has n,        :hashtags
# end
#
#
#
# class AtSign
#   # # atsigned
#   property      :posting_user
#   property      :status_id
#   property      :atsigned_user
#   belongs_to    :status
#   belongs_to    :user
#   belongs_to    :user
# end
#
# class Link
#   # link
#   property      :status_id
#   property      :url
#   belongs_to    :status
# end
#
# class HashTag
#   # hashtag
#   property      :posting_user
#   property      :status_id
#   property      :hashtag
#   belongs_to    :status
#   belongs_to    :user
# end

