#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'json'
require 'cassandra' ; include Cassandra::Constants
require File.dirname(__FILE__)+'/periodic_logger'
require File.dirname(__FILE__)+'/cassandra_db'

OLD_CASSANDRA_DB_SEEDS = %w[10.242.214.96 10.195.113.220 10.195.115.240 10.196.230.63].map{|host| host+':9160' }

#
# Load precomputed json data into the ApeyEye database.
#
#   ~/ics/icsdata/social/network/twitter/apeyeye//extract_wordbag_with_kludge.rb  --rm --run /data/sn/tw/fixd/objects/twitter_user_id_matched /data/sn/tw/fixd/word/extracted_user_wordbag_json
#
class WordbagBulkSucker < Wukong::Streamer::Base
  include CassandraDb 
  def log() @log ||= PeriodicLogger.new ; end

  def process rsrc, user_id, scraped_at, screen_name, *_
    user_id     = nil if user_id.blank?
    screen_name = nil if screen_name.blank?
    return unless user_id || screen_name

    wordbag_json = safely("Get wordbag for #{user_id} from old db") do 
      old_cassandra_db.get(:Users, user_id, 'wordbag_json') or return
    end
    log.periodically(user_id, screen_name)
    yield [user_id, screen_name, wordbag_json]
  end

  # Pull from old database
  def old_cassandra_db
    @old_cassandra_db ||= Cassandra.new('Twitter', OLD_CASSANDRA_DB_SEEDS)
  end

  # Dump log info at end of run
  def after_stream() $stderr.puts log.progress("Done") end
end

Wukong::Script.new( WordbagBulkSucker, nil ).run
