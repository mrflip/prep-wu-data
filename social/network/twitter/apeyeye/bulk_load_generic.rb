#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/bulk_load_streamer'

#
# Load precomputed json data into the ApeyEye database.
#
#   ~/ics/icsdata/social/network/twitter/apeyeye/bulk_loader.rb --dataset=influence --rm --run --batch_size=200 /data/sn/tw/fixd/apeyeye/influence/reply_json /tmp/bulkload/influence
#
#
class BulkLoadJsonAttribute < BulkLoadStreamer
  def process user_id, json
    return if json.blank? || user_id.blank?
    db.insert(user_id, json)
    log.periodically{ print_progress }
  end

  def db
    @db ||= TokyoDbConnection::TyrantDb.new(('tw_'+options.dataset).to_sym)
  end

  # track progress --
  #
  # NOTE: emits to stdout, since other output is going to DB
  #
  def print_progress
    emit         log.progress(db.size)
    $stderr.puts log.progress(db.size)
  end
end
Wukong::Script.new(
  BulkLoadJsonAttribute,
  nil,
  :map_speculative => "false",
  :max_maps_per_node => 2
  ).run
