#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/bulk_load_streamer'

Settings.dataset = 'word_stats2'

#
# Load precomputed json data into the ApeyEye database.
#
#   ~/ics/icsdata/social/network/twitter/apeyeye/bulk_load_word_stats.rb    --rm --run --log_interval=10000 s3n://infochimps-data/data/soc/net/tw/pkgd/global_word_stats_json_20100730 /tmp/bulkload/word_stats
#
class BulkLoadWordStats < BulkLoadStreamer

  def process  word, old_json
    return if [word, old_json].any?(&:blank?)
    json_str = repair_json_str(word, old_json) or return
    puts json_str
    # db.insert(word.to_s, json_str)
    # log.periodically{ print_progress(word, json_str) }
  end

  # Numeric-ify fields
  def repair_json_str word, old_json
    oldhsh = safely_parse_json(old_json)
    newhsh = {}
    # 1088      {"user_freq_avg":"0.003907669","rel_freq_ppb":"171.67966","token":"1088","global_freq_avg":"1.12319704E-7","user_freq_stdev":"0.012098187","range":"1534","dispersion":"0.9169312","total_usages":"2554","global_freq_stdev":"6.816125E-5"}
    oldhsh.keys.each do |key|
      case key
      when "rel_freq_ppb" then
        newhsh[:global_freq_ppb] = oldhsh[key].to_f
      when "global_freq_stdev" then
        newhsh[:global_stdev_ppb] = oldhsh[key].to_f*1_000_000_000.0
      when "range" then
        newhsh[:range] = oldhsh[key].to_f / 53_368_769.0
      when "token" then
        newhsh[:tok] = oldhsh[key]
      end
    end
    newhsh.to_json
  end
end

Wukong::Script.new(
  BulkLoadWordStats,
  nil,
  :map_speculative => "false",
  :max_maps_per_node => 2
  ).run
