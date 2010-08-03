#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/bulk_load_streamer'
require 'json'

Settings.dataset = 'influence2'

#
# Load precomputed json data into the ApeyEye database.
#
#   ~/ics/icsdata/social/network/twitter/apeyeye/bulk_load_influence_json.rb --rm --run --log_interval=20000  /data/sn/tw/fixd/apeyeye/influence/a_replies_b_json /tmp/bulkload/influence
# or
#   hdp-catd /data/sn/tw/fixd/apeyeye/influence/a_replies_b_json | ~/ics/icsdata/social/network/twitter/apeyeye/bulk_load_influence.rb --map --log_interval=100000 > /mnt/tmp/bulkload_influence.log
#
class BulkLoadInfluence < BulkLoadStreamer
  # Oops on user_id is a string in the json
  def repair_influence_json user_id, old_json
    begin
      oldhsh = JSON.load(old_json)
    rescue StandardError => e
      puts [old_json, e, e.backtrace].join("\t")
      warn [old_json, e, e.backtrace].join("\t")
      return
    end
    oldhsh['user_id'] = user_id.to_i
    oldhsh.to_json
  end

  def process  user_id, influence_json
    return if influence_json.blank? || user_id.blank?
    influence_json = repair_influence_json(user_id, influence_json) or return
    db.insert(user_id.to_s, influence_json)
    log.periodically{ print_progress }
  end
end

Wukong::Script.new(
  BulkLoadInfluence,
  nil,
  :map_speculative => "false",
  :max_maps_per_node => 2
  ).run
