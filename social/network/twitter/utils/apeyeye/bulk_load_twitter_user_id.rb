#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'json'
require 'cassandra' ; include Cassandra::Constants

Settings.define :keyspace, :default => 'Twitter', :description => 'Cassandra keyspace'

#
# Load precomputed json data into the ApeyEye database.
#
#   ~/ics/icsdata/social/network/twitter/utils/apeyeye/bulk_loader.rb --dataset=influence --rm --run /data/sn/tw/fixd/infl_metrics/reply_json /tmp/bulkload/influence
#
#

class BulkLoader < Wukong::Streamer::RecordStreamer
  def initialize *args
    super *args
    @cassandra_db       = Cassandra.new(Settings.keyspace, %w[ 10.194.11.47 10.194.61.123 10.194.61.124 10.194.99.239 10.195.219.63 10.212.102.208 10.212.66.132 10.218.55.220 ].map{|s| "#{s}:9160"})
    @iter = 0
  end

  def process rsrc, user_id, scraped_at, screen_name, is_protected, followers_count, friends_count, statuses_count, favourites_count, created_at, search_id, is_full, *_
    begin
      @cassandra_db.insert(:Users, user_id, {
          :scraped_at => scraped_at, :screen_name => screen_name,
          :followers_count => followers_count, :friends_count => friends_count, :statuses_count => statuses_count, :favourites_count => favourites_count,
          :created_at => created_at, :search_id => search_id, :is_full => is_full },
        :consistency => Cassandra::Consistency::ANY)
      @cassandra_db.insert(:Usernames,     screen_name, { :user_id => user_id, :search_id   => search_id   }, :consistency => Cassandra::Consistency::ANY)
      @cassandra_db.insert(:UserSearchIds, screen_name, { :user_id => user_id, :screen_name => screen_name }, :consistency => Cassandra::Consistency::ANY)
    rescue StandardError => e ; warn "Insert failed: #{e}" end
    if (@iter+=1) % 10_000 == 0 then yield(json) ; $stderr.puts [@iter, screen_name, user_id].join("\t") end
  end
end

Wukong::Script.new( BulkLoader, nil ).run
