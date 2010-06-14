#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'json'
require 'cassandra' ; include Cassandra::Constants
require File.dirname(__FILE__)+'/cassandra_bulk_load_streamer'

#
# Load precomputed json data into the ApeyEye database.
#
#   ~/ics/icsdata/social/network/twitter/apeyeye/id_lookup/bulk_load_twitter_user_id.rb --rm --run /data/sn/tw/fixd/objects/twitter_user_id_matched /tmp/bulkload/twitter_user_id
#
#
class TwitterIdsBulkLoader < CassandraBulkLoadStreamer

  def process rsrc, user_id, scraped_at, screen_name, is_protected, followers_count, friends_count, statuses_count, favourites_count, created_at, search_id, is_full, *_, &block
    user_id     = nil if user_id.blank?
    screen_name = nil if screen_name.blank?
    search_id   = nil if search_id.blank?
    db_insert(:Users, user_id, {
        "scraped_at" => scraped_at, "screen_name" => screen_name,
        "followers_count" => followers_count, "friends_count" => friends_count, "statuses_count" => statuses_count, "favourites_count" => favourites_count,
        "created_at" => created_at, "search_id" => search_id, "is_full" => is_full              }.compact) if user_id
    db_insert(:Usernames,     screen_name, { "user_id" => user_id, "search_id"   => search_id   }.compact) if screen_name
    db_insert(:UserSearchIds, search_id,   { "user_id" => user_id, "screen_name" => screen_name }.compact) if search_id
  end

end
Wukong::Script.new( BulkLoader, nil ).run
