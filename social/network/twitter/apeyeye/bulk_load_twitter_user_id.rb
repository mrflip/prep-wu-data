#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'json'
require 'configliere' ; require 'configliere/commandline'
require 'wukong/keystore/tyrant_db' ; include TokyoDbConnection
require File.dirname(__FILE__)+'/periodic_logger'

class TwitterIdsBulkLoader < Wukong::Streamer::RecordStreamer

  UID_DB = TyrantDb.new(:user_ids)
  SN_DB  = TyrantDb.new(:screen_names)
  SID_DB = TyrantDb.new(:search_ids)
  
  def process rsrc, user_id, scraped_at, screen_name, is_protected, followers_count, friends_count, statuses_count, favourites_count, created_at, search_id, is_full, *_, &block
    user_id     = nil if user_id.empty?
    screen_name = nil if screen_name.empty?
    search_id   = nil if search_id.empty?
    UID_DB.insert_array(user_id,
      [ scraped_at, screen_name, is_protected, followers_count,
        friends_count, statuses_count, favourites_count, created_at ]) if user_id
    SN_DB.insert(screen_name.downcase, user_id.to_s) if screen_name
    SID_DB.insert(search_id, screen_name.downcase)   if search_id
    # if user_id     then ; UID_DB[user_id]             or yield ['user_id_missing', user_id] ; end
    # if screen_name then ; SN_DB[screen_name.downcase] or yield ['screen_name_missing', screen_name] ; end
    # if search_id   then ; SID_DB[search_id]           or yield ['search_id_missing', search_id] ; end
    log.periodically do
      yield  log.progress("%7d"%user_id, "%7d"%screen_name)
      $stderr.puts log.progress("%7d"%user_id, "%7d"%screen_name)
    end
  end

end

Wukong::Script.new( TwitterIdsBulkLoader, nil ).run
