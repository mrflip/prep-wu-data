#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/bulk_load_streamer'

Settings.dataset = 'strong_links2'

#
# Load precomputed json data into the ApeyEye database.
#
#   ~/ics/icsdata/social/network/twitter/apeyeye/bulk_load_strong_links.rb  --rm --run --log_interval=10000 s3n://infochimps-data/data/soc/net/tw/pkgd/strong_links_json_20100729 /tmp/bulkload/strong_links
#
class BulkLoadStrongLinks < BulkLoadStreamer
  def process  user_id, old_json
    return if [user_id, old_json].any?(&:blank?)
    json_str = repair_json_str(user_id, old_json) or return
    db.insert(user_id.to_s, json_str)
    log.periodically{ print_progress(user_id, json_str) }
  end

  def repair_json_str user_id, old_json
    oldhsh = safely_parse_json(old_json)
    return unless oldhsh && oldhsh["strong_links"]
    oldhsh["user_id"] = user_id.to_i
    oldhsh["strong_links"].map! do |pair|
      nbr_id, nbr_tw = [pair["user_id"].to_i, pair["weight"].to_f];
      next if nbr_id == user_id.to_i
      nbr_tw = 0.05 if nbr_tw <= 0.05
      [nbr_id, nbr_tw]
    end
    oldhsh.to_json
  end

end
Wukong::Script.new(
  BulkLoadStrongLinks,
  nil,
  :map_speculative => "false",
  :max_maps_per_node => 2
  ).run
