#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'json'
require 'cassandra' ; include Cassandra::Constants
require File.dirname(__FILE__)+'/cassandra_bulk_load_streamer'

#
# Load precomputed json data into the ApeyEye database.
#
#   ~/ics/icsdata/social/network/twitter/apeyeye/bulk_load_wordbag_json.rb --rm --run /data/sn/tw/fixd/apeyeye/wordbag /tmp/bulkload/wordbag
#
#
class BulkLoadWordbag < CassandraBulkLoadStreamer

  def process  user_id, wordbag_json
    next if json.blank? || user_id.blank?
    db_insert(:UserWordbags, user_id, { "wordbag_json" => wordbag_json })
  end

end
Wukong::Script.new( BulkLoadWordbag, nil ).run

