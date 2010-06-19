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

  def initialize *args
    super(*args)
    @iter = 0
    @log = PeriodicLogger.new(options)
  end

  def process rsrc, user_id, scraped_at, screen_name, is_protected, followers_count, friends_count, statuses_count, favourites_count, created_at, search_id, is_full, *_, &block
    user_id     = (user_id.blank?     ? nil : user_id )
    screen_name = (screen_name.blank? ? nil : screen_name.downcase)
    $stderr.puts "screwy screen_name: #{screen_name}" if screen_name =~ /[^\w]/
    search_id   = (search_id.blank?   ? nil : search_id )

    if Settings[:read]
      if user_id     then ; UID_DB[user_id]    or yield ['user_id_missing', user_id]         ; end
      if screen_name then ; SN_DB[screen_name] or yield ['screen_name_missing', screen_name] ; end
      if search_id   then ; SID_DB[search_id]  or yield ['search_id_missing', search_id]     ; end
    else
      UID_DB.insert(user_id,     screen_name)  if user_id     && screen_name
      SN_DB.insert( screen_name, user_id)      if screen_name && user_id
      SID_DB.insert(search_id,   screen_name)  if search_id   && screen_name
    end

    @log.periodically do
      $stderr.puts @log.progress('user_id', "%10d"%user_id, 'screen_name', screen_name)
      yield        [user_id, screen_name]
    end
  end

end

Wukong::Script.new( TwitterIdsBulkLoader, nil ).run
