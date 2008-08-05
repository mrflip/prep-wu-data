require 'rubygems'
require 'dm-ar-finders'

class User
  include DataMapper::Resource
  # Basic info
  property      :id,                         Integer,           :serial => true
  property      :twitter_name,               String,            :nullable => false, :unique_index => :twitter_name  # should be :unique_index
  property      :file_date,                  DateTime
  property      :twitter_id,                 Integer
  property      :parsed,                     Boolean

  #
  property      :following_count,            Integer
  property      :followers_count,            Integer
  property      :favorites_count,            Integer
  property      :updates_count,              Integer

  #
  property      :real_name,                  String, :length => 255
  property      :location,                   Text
  property      :web,                        Text
  property      :bio,                        Text

  # Page appearance
  property      :style_profile_img_url,      Text
  property      :style_mini_img_url,         Text
  property      :style_bg_img_url,           Text

  property      :style_name_color,           Integer
  property      :style_link_color,           Integer
  property      :style_text_color,           Integer
  property      :style_bg_color,             Integer
  property      :style_sidebar_fill_color,   Integer
  property      :style_sidebar_border_color, Integer
  property      :style_bg_img_tile,          Boolean

  # Status info on page
  property      :latest_update_time,         DateTime
  property      :pg1_first_update_time,      DateTime

  #
  # Associations
  #
  has n, :friends,     :child_key => [:follower_id], :class_name => 'Friendship'
  has n, :followers,   :child_key => [:friend_id],   :class_name => 'Friendship'

  def seen_profile_page
    self.file_date
  end

  def profile_page_filename()     path_to [:ripd, "profiles",  filename_path]  end
  def filename_path
    first_two = (twitter_name.length==1) ? twitter_name[0..0]+'_' : twitter_name[0..1]
    first_two.downcase!
    filename = "twitter_id_#{first_two}/#{twitter_name}"
  end
  def self.err_404s_filename()    path_to [:fixd, "stats/twitter_404s.yaml"]   end

  def self.users_with_profile
    #Dir[path_to(:ripd, "profiles/twitter_id_*")].each do |dir|
    Dir[path_to(:temp, "profiles/simple")].each do |dir|
      Dir[dir+'/*'].each do |profile_page|
        user = User.find_or_create(:twitter_name => File.basename(profile_page))
        yield user
      end
    end
  end

end

#
# Following
#
class Friendship
  include DataMapper::Resource
  # property      :id,            Integer, :serial => true
  property      :follower_id,   Integer,                :key => true
  property      :friend_id,     Integer,                :key => true, :index => :friend_id
  belongs_to    :follower,      :class_name => 'User',  :child_key => [:follower_id]
  belongs_to    :friend,        :class_name => 'User',  :child_key => [:friend_id]
end

#
#   #
#   # Status
#   #
# class Status
#   include DataMapper::Resource
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
#   include DataMapper::Resource
#   property      :posting_user
#   property      :status_id
#   property      :atsigned_user
#   belongs_to    :status
#   belongs_to    :user
#   belongs_to    :user
# end
#
# class Link
#   include DataMapper::Resource
#   property      :status_id
#   property      :url
#   belongs_to    :status
# end
#
# class HashTag
#   include DataMapper::Resource
#   property      :posting_user
#   property      :status_id
#   property      :hashtag
#   belongs_to    :status
#   belongs_to    :user
# end
