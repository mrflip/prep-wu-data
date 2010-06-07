#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'json'
require 'cassandra' ; include Cassandra::Constants

Settings.define :dataset,    :default => 'trstrank', :description => 'dataset to load, eg. trstrank, wordbag or influence'

#
# Load precomputed json data into the ApeyEye database.
#
#   ~/ics/icsdata/social/network/twitter/utils/apeyeye/bulk_loader.rb --dataset=influence --rm --run /data/sn/tw/fixd/infl_metrics/reply_json /tmp/bulkload/influence
#
#

class BulkLoader < Wukong::Streamer::RecordStreamer
  def initialize *args
    super *args
    # database connection
    @cassandra_db       = Cassandra.new('SocNetTw', %w[ 10.194.11.47 10.194.61.123 10.194.61.124 10.194.99.239 10.195.219.63 10.212.102.208 10.212.66.132 10.218.55.220 ].map{|s| "#{s}:9160"})
    @cf_for_user_id     = self.options.dataset+'_user_id'
    @cf_for_screen_name = self.options.dataset+'_screen_name'
    @iter = 0
  end

  def process screen_name, user_id, json
    screen_name.downcase!
    begin
      @cassandra_db.insert @cf_for_user_id,     user_id,     {'json' => json, 'screen_name' => screen_name }, :consistency => Cassandra::Consistency::ZERO unless user_id.blank?
      @cassandra_db.insert @cf_for_screen_name, screen_name, {'json' => json, 'user_id'     => user_id     }, :consistency => Cassandra::Consistency::ZERO unless screen_name.blank?
    rescue RuntimeError => e ; warn "Insert failed: #{e}" end
    if (@iter+=1) % 10_000 == 0 then yield(json) ; $stderr.puts [@iter, screen_name, user_id, json].join("\t") end
  end
end

Wukong::Script.new( BulkLoader, nil ).run
