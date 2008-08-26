module IMW
  def setup_twitter_friends_connection
    hostname = `hostname -s`.chomp
    DataMapper::setup(:default, "sqlite3:///#{File.dirname(__FILE__)}/fixd/db/twitter_friends-#{hostname}.sqlite")
  end
end
