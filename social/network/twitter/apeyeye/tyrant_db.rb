require 'tokyo_tyrant'
require 'tokyo_tyrant/balancer'
# Settings.define :batch_size,   :default => 50, :type => Integer, :description => 'Thrift buffer batch size'

# -- Starting
#    ttserver -port 12009 -ulog /mnt/tmp/ttyrant/test-ulog.db -ulim 268435456 -uas '/data/db/ttyrant/test.tch#bnum=200 000 000#opts=l#rcnum=100000#xmsiz=536870912
#    also: http://copiousfreetime.rubyforge.org/tyrantmanager/
#
# -- Monitoring
#    tcrmgr inform -port $port -st $hostname
#    active conns:
#    lsof  -i | grep ttserver | wc -l
#
#    use db.rnum for most lightweight ping method
#
# -- Tuning
#    http://korrespondence.blogspot.com/2009/09/tokyo-tyrant-tuning-parameters.html
#    http://groups.google.com/group/tokyocabinet-users/browse_thread/thread/5a46ee04006a791c#
#    opts     "l" of large option (the size of the database can be larger than 2GB by using 64-bit bucket array.), "d" of Deflate option (each record is compressed with Deflate encoding), "b" of BZIP2 option, "t" of TCBS option
#    bnum     number of elements of the bucket array. If it is not more than 0, the default value is specified. The default value is 131071 (128K). Suggested size of the bucket array is about from 0.5 to 4 times of the number of all records to be stored.
#    rcnum    maximum number of records to be cached. If it is not more than 0, the record cache is disabled. It is disabled by default.
#    xmsiz    size of the extra mapped memory. If it is not more than 0, the extra mapped memory is disabled. The default size is 67108864 (64MB).
#    apow     size of record alignment by power of 2. If it is negative, the default value is specified. The default value is 4 standing for 2^4=16.
#    fpow     maximum number of elements of the free block pool by power of 2. If it is negative, the default value is specified. The default value is 10 standing for 2^10=1024.
#    dfunit   unit step number of auto defragmentation. If it is not more than 0, the auto defragmentation is disabled. It is disabled by default.
#    mode     "w" of writer, "r" of reader,"c" of creating,"t" of truncating ,"e" of no locking,"f" of non-blocking lock
#
# -- Links
#    http://1978th.net/tokyocabinet/spex-en.html
#    http://groups.google.com/group/tokyocabinet-users/browse_thread/thread/3bd2a93322c09eec#

class TyrantDb
  attr_reader :dataset
  DB_SERVERS = [
    '10.218.47.247',
    '10.218.1.178',
    '10.218.71.212',
    '10.194.93.123',
    '10.195.77.171',
    '10.244.142.192',
  ]

  DB_PORTS = {
    :uid => 12001,
    :sn  => 12002,
    # :sid => 12003,
    :tweets_parsed => 12004,
    :users_parsed  => 12005,
    :test => 12009,
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

  def [](*args)    ; db[*args]               ; end
  def close(*args) ; @db.close(*args) if @db ; end

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
      db.get(key)
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

