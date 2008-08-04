require 'imw/utils'
require 'imw/dataset'
include IMW

class TwitterUser

  attr_reader :twitter_name
  attr_accessor :n_followers, :n_following

  def initialize(twitter_name)
    @twitter_name = twitter_name
  end

  def following_filename()        path_to [:fixd, "following", filename_path]  end
  def followers_filename()        path_to [:fixd, "followers", filename_path]  end
  def profile_page_filename()     path_to [:ripd, "profiles",  filename_path]  end
  def filename_path
    first_two = (twitter_name.length==1) ? twitter_name[0..0]+'_' : twitter_name[0..1]
    first_two.downcase!
    filename = "twitter_id_#{first_two}/#{twitter_name}"
  end
  def self.names_index_filename() path_to [:fixd, "stats/twitter_names.yaml"]  end
  def self.err_404s_filename()    path_to [:fixd, "stats/twitter_404s.yaml"]   end
  def self.histogram_filename()   path_to [:fixd, "stats/twitter_hist.yaml"]   end

  def self.load_users_index
    twitter_names = DataSet.load(TwitterUser.names_index_filename)
    twitter_users = []
    twitter_names[:names].each do |name, n_followers|
      u = TwitterUser.new(name)
      u.n_followers = n_followers
      twitter_users << u
    end
    twitter_users
  end

  def self.users_with_profile
    Dir[path_to(:ripd, "profiles/*")].each do |dir|
      # track_progress :profile_directory, File.basename(dir)
      Dir[dir+'/*'].each do |profile_page|
        twitter_name = File.basename(profile_page)
        user = TwitterUser.new(twitter_name)
        yield user
      end
    end
  end


end
