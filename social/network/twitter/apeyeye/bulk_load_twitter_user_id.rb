#!/usr/bin/env ruby
require 'rubygems'
require File.dirname(__FILE__)+'/bulk_load_streamer'

Settings.dataset = 'user_info'

#
# Load user data into the Apeyeye database
#
#   ~/ics/icsdata/social/network/twitter/apeyeye/bulk_load_twitter_user_id.rb --run --rm --log_interval=10000  /data/sn/tw/fixd/objects/twitter_user_id_matched  /tmp/bulk_load_twitter_user_id
#
class BulkLoadTwitterUserIds < BulkLoadStreamer
  USER_DB = TokyoDbConnection::TyrantDb.new(:tw_user_info)
  SN_DB   = TokyoDbConnection::TyrantDb.new(:screen_names)
  SID_DB  = TokyoDbConnection::TyrantDb.new(:search_ids)

  def process rsrc, user_id, scraped_at, screen_name, is_protected, followers_count, friends_count, statuses_count, favourites_count, created_at, search_id, is_full, *_, &block
    user_id     = (user_id.blank?     ? nil : user_id )
    screen_name = (screen_name.blank? ? nil : screen_name.downcase)
    search_id   = (search_id.blank?   ? nil : search_id )

    user_info = { :user_id => user_id, :screen_name => screen_name, :search_id => search_id, :created_at => created_at }.compact

    USER_DB.insert(user_id,     user_info.to_json) if user_id
    SN_DB.insert(  screen_name, user_id)        if screen_name && user_id
    SID_DB.insert( search_id,   screen_name)    if search_id   && screen_name

    log.periodically{ print_progress }
  end

  # track progress --
  #
  # NOTE: emits to stdout, since other output is going to DB
  #
  def print_progress
    emit         log.progress(USER_DB.size, SN_DB.size, SID_DB.size)
    $stderr.puts log.progress(USER_DB.size, SN_DB.size, SID_DB.size)
  end
end

Wukong::Script.new( BulkLoadTwitterUserIds, nil, :map_speculative => "false" ).run
