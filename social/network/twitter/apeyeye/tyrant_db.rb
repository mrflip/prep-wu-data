require 'tokyo_tyrant'
require 'tokyo_tyrant/balancer'
# Settings.define :batch_size,   :default => 50, :type => Integer, :description => 'Thrift buffer batch size'

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
      cassandra_db.get(*args)
    rescue StandardError => e ; handle_error("Fetch #{key}", e); end    
  end

  def handle_error action, e
    warn "#{action} failed: #{e} #{e.backtrace.join("\t")}" ;
    @cassandra_db = nil
    sleep 0.2
  end
end
