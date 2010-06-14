#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'json'
require 'cassandra' ; include Cassandra::Constants
require File.dirname(__FILE__)+'/cassandra_bulk_load_streamer'

Settings.define :dataset,    :required => true, :description => 'dataset to load, eg. trstrank, wordbag or influence'

#
# Load precomputed json data into the ApeyEye database.
#
#   ~/ics/icsdata/social/network/twitter/apeyeye/bulk_load_twitter_user_id.rb       --rm --run --batch_size=200 /data/sn/tw/fixd/objects/twitter_user_id_matched /tmp/bulkload/twitter_user_ids
#   ~/ics/icsdata/social/network/twitter/apeyeye/bulk_loader.rb --dataset=influence --rm --run --batch_size=200 /data/sn/tw/fixd/apeyeye/influence/reply_json /tmp/bulkload/influence
#
#
class BulkLoadJsonAttribute < CassandraBulkLoadStreamer
  def initialize *args
    super *args
    @dataset_col = options.dataset + '_json'
  end

  def process  screen_name, user_id, json
    next if json.blank? || user_id.blank?
    db_insert(:UserJson, user_id, { @dataset_col => json })
  end

end
Wukong::Script.new( BulkLoadJsonAttribute, nil ).run
