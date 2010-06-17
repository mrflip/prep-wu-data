require 'tokyo_tyrant'
require 'tokyo_tyrant/balancer'
# Settings.define :batch_size,   :default => 50, :type => Integer, :description => 'Thrift buffer batch size'


# ttserver -port 12001 /data/db/ttyrant/twitter_user-uid.tch#bnum=100000000#opts=l ; ttserver -port 12002 /data/db/ttyrant/twitter_user-sn.tch#bnum=100000000#opts=l ; ttserver -port 12003 /data/db/ttyrant/twitter_user-sid.tch#bnum=100000000#opts=l

class TyrantDb
  attr_reader :dataset
  DB_SERVERS = [
    '10.218.47.247',
    '10.194.93.123',
    '10.195.77.171',
    '10.218.1.178',
    '10.218.71.212',
  ] 
  #   '10.244.142.192',

  DB_PORTS = {
    :uid => 12001,
    :sn  => 12002,
    :sid => 12003,
  }

  def initialize dataset
    @dataset = dataset
  end
  
  def db
    return @db if @db
    port = DB_PORTS[dataset] or raise "Don't know how to reach dataset #{dataset}"
    @db = TokyoTyrant::Balancer::DB.new(DB_SERVERS.map{|s| s+':'+port.to_s})
    # @db = TokyoTyrant::DB.new(DB_SERVERS.first, port.to_i)
    p @db
    @db
  end

  def [](*args) ; db[*args] ; end

  #
  # Insert into the cassandra database with default settings
  #
  def insert key, value
    begin
      db.putnr(key, value)
    rescue StandardError => e ; handle_error("Insert #{[key, value].inspect}", e); end
  end

  def insert_array key, value
    insert(key, value.join(','))
  end

  def get key
    begin
      db.get(*args)
    rescue StandardError => e ; handle_error("Fetch #{key}", e); end    
  end

  def handle_error action, e
    warn "#{action} failed: #{e} #{e.backtrace.join("\t")}" ;
    @db = nil
    sleep 0.2
  end

  def invalidate!
    @db = nil
  end
end


# class TwitterUser
#   TWITTER_USER_DB = TyrantDb.new(:uid)
#   
#   def store_into_db!
#     TWITTER_USER_DB.insert_array(user_id,
#       [ scraped_at, screen_name, created_at, search_id, followers_count, friends_count, statuses_count]
#       ) if user_id
#   end
# 
#   def get_screen_name id
#     TWITTER_USER_DB.get_array()
#   end
# 
#   def rectify_sn_from_id! 
#     return if user_id.blank? || (not self.screen_name.blank?)
#     self.screen_name = SN_DB.get(:Users, user_id.to_s, 'screen_name')
#   end
# 
#   def rectify_id_from_sn! db_connection
#     return if screen_name.blank? || (not self.user_id.blank?)
#     self.user_id = db_connection.get(:Usernames, screen_name.to_s, 'user_id')
#   end
# 
#   def self.should_emit? db_connection, user_id, timestamp
#     return true
#     db_scraped_at = db_connection.get(:Users, user_id.to_s, 'scraped_at')
#     db_scraped_at.blank? || (db_scraped_at < timestamp)
#   end
# 
# end


TalksToDb.new
