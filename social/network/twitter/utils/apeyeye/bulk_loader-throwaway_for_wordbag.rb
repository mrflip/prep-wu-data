#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'json'
require 'cassandra' ; include Cassandra::Constants

LOGGING_INTERVAL = 10_000

#
# Load precomputed json data into the ApeyEye database.
#
#   ~/ics/icsdata/social/network/twitter/utils/apeyeye/bulk_loader.rb --dataset=influence --rm --run /data/sn/tw/fixd/infl_metrics/reply_json /tmp/bulkload/influence
#
#

class BulkLoader < Wukong::Streamer::RecordStreamer
  def initialize *args
    super *args
    @cassandra_db = Cassandra.new('SocNetTw', %w[ 10.194.11.47 10.194.61.123 10.194.61.124 10.194.99.239 10.195.219.63 10.212.102.208 10.212.66.132 10.218.55.220 ].map{|s| "#{s}:9160"})
    @iter = 0
  end

  def process screen_name_or_user_id, json
    screen_name_or_user_id.downcase!
    @cf_key = 'wordbag_'+((screen_name_or_user_id =~ /^\d+$/) ? 'user_id' : 'screen_name')
    begin
      @cassandra_db.insert @cf_key, screen_name_or_user_id, {'json' => json}, :consistency => Cassandra::Consistency::ZERO unless screen_name_or_user_id.blank?
    rescue RuntimeError => e ; warn "Insert failed: #{e}" end
    if (@iter+=1) % LOGGING_INTERVAL == 0 then yield(json) ; $stderr.puts [@iter, screen_name_or_user_id, json].join("\t") end
  end
end

Wukong::Script.new( BulkLoader, nil ).run
