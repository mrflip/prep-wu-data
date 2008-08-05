module IMW
  def setup_twitter_friends_connection
    DataSet.setup_connection :mysql, 'imw', 'local_pass_14_312', 'localhost', 'imw_twitter_friends'
    # DataMapper::setup(:default, "sqlite3:///#{Dir.pwd}/fixd/db/twitter_friends.sqlite")
  end
end
