#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/bulk_load_streamer'

Settings.dataset = 'conversation'

#
# Load precomputed json data into the ApeyEye database.
#
#   ~/ics/icsdata/social/network/twitter/apeyeye/bulk_load_conversation_json.rb --rm --run --log_interval=20000  /data/sn/tw/fixd/apeyeye/conversation/a_replies_b_json /tmp/bulkload/conversation
# or
#   hdp-catd /data/sn/tw/fixd/apeyeye/conversation/a_replies_b_json | ~/ics/icsdata/social/network/twitter/apeyeye/bulk_load_conversation.rb --map --log_interval=100000 > /mnt/tmp/bulkload_conversation.log
#
class BulkLoadConversation < BulkLoadStreamer

  def process  user_a_id, user_b_id, conversation_json
    return if conversation_json.blank? || user_a_id.blank? || user_b_id.blank?
    @db.insert("#{user_a_id}:#{user_b_id}", conversation_json)
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
Wukong::Script.new( BulkLoadConversation, nil ).run

