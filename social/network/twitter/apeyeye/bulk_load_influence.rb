#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/bulk_load_streamer'

Settings.dataset = 'influence2'

#
# Load precomputed json data into the ApeyEye database.
#
#   ~/ics/icsdata/social/network/twitter/apeyeye/bulk_load_influence.rb    --rm --run --log_interval=10000 s3n://infochimps-data/data/soc/net/tw/pkgd/influencer_metrics_json_20100729 /tmp/bulkload/influence
#
class BulkLoadInfluence < BulkLoadStreamer

  def process  user_id, old_json
    return if [user_id, old_json].any?(&:blank?)
    json_str = repair_json_str(user_id, old_json) or return
    db.insert(user_id.to_s, json_str)
    log.periodically{ print_progress(user_id, json_str) }
  end
  
  # Oops on user_id is a string in the json
  def repair_json_str user_id, old_json
    oldhsh = safely_parse_json(old_json)
    oldhsh['user_id'] = user_id.to_i
    oldhsh.to_json
  end
end

Wukong::Script.new(
  BulkLoadInfluence,
  nil,
  :map_speculative => "false",
  :max_maps_per_node => 2
  ).run
