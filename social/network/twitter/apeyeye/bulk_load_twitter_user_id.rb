#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'json'
require 'configliere' ; require 'configliere/commandline'
require File.dirname(__FILE__)+'/batch_streamer'
require File.dirname(__FILE__)+'/periodic_logger'
require File.dirname(__FILE__)+'/tyrant_db'

#
# Load precomputed json data into the ApeyEye database.
#
#   ~/ics/icsdata/social/network/twitter/apeyeye/bulk_load_twitter_user_id.rb --rm --run --batch_size=200 /data/sn/tw/fixd/objects/twitter_user_id_matched /tmp/bulkload/twitter_user_ids
#
class TwitterIdsBulkLoader < BatchStreamer

  UID_DB = TyrantDb.new(:uid)
  SN_DB  = TyrantDb.new(:sn)
  SID_DB = TyrantDb.new(:sid)

  def process rsrc, user_id, scraped_at, screen_name, is_protected, followers_count, friends_count, statuses_count, favourites_count, created_at, search_id, is_full, *_, &block
    user_id     = nil if user_id.empty?
    screen_name = nil if screen_name.empty?
    search_id   = nil if search_id.empty?
    UID_DB.insert_array(user_id,
      [ scraped_at, screen_name, created_at, search_id,
        followers_count, friends_count, statuses_count]) if user_id
    SN_DB.insert(screen_name.downcase, user_id) if screen_name
    SID_DB.insert(search_id, user_id)           if search_id
    log.periodically do
      emit         log.progress("%7d"%@batch_size, "%7d"%batch_count)
      $stderr.puts log.progress("%7d"%@batch_size, "%7d"%batch_count)
    end
  end

  #
  # stores up commits within this block, and passes them all at once to
  #
  # Note that this is nothing like a transaction: it's just a way to make the
  # Thrift interface slightly less wasteful.
  def batch &block
    block.call
  end

end
Wukong::Script.new( TwitterIdsBulkLoader, nil ).run
