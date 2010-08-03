#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/bulk_load_streamer'

Settings.dataset = 'screen_names2'

#
#   ~/ics/icsdata/social/network/twitter/apeyeye/bulk_load_sn_id_mapping.rb --run --rm --log_interval=10000  s3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/objects/twitter_user_id /tmp/bulkload/twitter_user_id
#
class BulkLoadJsonAttribute < BulkLoadStreamer

  def process rsrc, uid, scat, sn, *args
    return if [sn, uid].any?(&:blank?)
    db.insert(sn.downcase, uid)
    log.periodically{ print_progress(sn, uid) }
  end

end

Wukong::Script.new(
  BulkLoadJsonAttribute,
  nil,
  :map_speculative => "false",
  :max_maps_per_node => 2
  ).run
