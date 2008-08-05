
class User
  include DataMapper::Resource
  # Basic info
  property      :id,                         Integer,           :serial => true
  property      :twitter_name,               String # ,            :nullable => false, :unique_index => :twitter_name
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

  property      :style_name_color,           Integer
  property      :style_link_color,           Integer
  property      :style_text_color,           Integer
  property      :style_bg_color,             Integer
  property      :style_sidebar_fill_color,   Integer
  property      :style_sidebar_border_color, Integer
  property      :style_bg_img_url,           String
  property      :style_bg_img_tile,          String

  # Status info on page
  property      :latest_update_time,         DateTime
  property      :pg1_first_update_time,      DateTime

  property      :followings,                  Text

  #
  # Associations
  #
  # has n, :followings
  has n, :followers, :class_name => self.name, :through => Resource
  #has n, :follows,   :through => :followings, :class_name => 'User'

  # has n,      :follows,                 :through => Following, :child_key => :follows_id
  #   :associated_class => 'User', :join_table => 'following'
  # has n,      :statuses

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
    Dir[path_to(:ripd, "profiles/twitter_id_za*")].each do |dir|
      # track_progress :profile_directory, File.basename(dir)
      Dir[dir+'/*'].each do |profile_page|
        twitter_name = File.basename(profile_page)
        user = User.new(:twitter_name => twitter_name)
        yield user
      end
    end
  end


end

#
# Following
#
class Following
  include DataMapper::Resource
  # belongs_to :user
  belongs_to :follower, :class_name => 'User'
  belongs_to :follow,   :class_name => 'User'
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

DataMapper.auto_migrate!
