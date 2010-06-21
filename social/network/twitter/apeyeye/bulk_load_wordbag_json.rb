#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/bulk_load_streamer'

Settings.dataset = 'wordbag'

#
# Load precomputed json data into the ApeyEye database.
#
#   ~/ics/icsdata/social/network/twitter/apeyeye/bulk_load_wordbag_json.rb --rm --run --log_interval=20000  /data/sn/tw/fixd/word/extracted_user_wordbag_json /tmp/bulkload/wordbag
#
class BulkLoadWordbag < BulkLoadStreamer

  def process  user_id, screen_name, wordbag_json
    next if wordbag_json.blank? || user_id.blank?
    @db.insert(user_id, wordbag_json)
    log.periodically{ print_progress }
  end

  # track progress --
  #
  # NOTE: emits to stdout, since other output is going to DB
  #
  def print_progress
    emit         log.progress(@db.size)
    $stderr.puts log.progress(@db.size)
  end
end
Wukong::Script.new( BulkLoadWordbag, nil ).run

