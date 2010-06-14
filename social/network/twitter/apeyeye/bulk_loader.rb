#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'json'
require 'cassandra' ; include Cassandra::Constants
require File.dirname(__FILE__)+'/batch_streamer'
require File.dirname(__FILE__)+'/periodic_logger'
require File.dirname(__FILE__)+'/cassandra_db'

Settings.define :dataset,    :required => true, :description => 'dataset to load, eg. trstrank, wordbag or influence'

#
# Load precomputed json data into the ApeyEye database.
#
#   ~/ics/icsdata/social/network/twitter/apeyeye/bulk_loader.rb --dataset=influence --rm --run --batch_size=200 /data/sn/tw/fixd/apeyeye/influence/reply_json /tmp/bulkload/influence
#
#
class BulkLoadJsonAttribute < BatchStreamer
  include CassandraDb
  def initialize *args
    super *args
    @dataset_col = options.dataset + '_json'
  end

  def process  screen_name, user_id, json
    next if json.blank? || user_id.blank?
    db_insert(:UserJson, user_id, { @dataset_col => json })
    log.periodically do
      emit         log.progress("%7d"%@batch_size, "%7d"%batch_count)
      $stderr.puts log.progress("%7d"%@batch_size, "%7d"%batch_count)
    end
  end

  def after_stream
    emit         log.progress("%7d"%@batch_size, "%7d"%batch_count)
    $stderr.puts log.progress("%7d"%@batch_size, "%7d"%batch_count)
  end

end
Wukong::Script.new( BulkLoadJsonAttribute, nil ).run
