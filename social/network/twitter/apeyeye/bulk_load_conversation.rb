#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/bulk_load_streamer'
require 'json'

Settings.dataset = 'conversation2'

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
    conversation_json = repair_conversation_json(user_a_id, user_b_id, conversation_json) or return
    db.insert("#{user_a_id}:#{user_b_id}", conversation_json)
    log.periodically{ print_progress }
  end

  # !! IMPORTANT !!
  # The order here is important, since we want me to lose to rt and re.
  # An RE should never also be an RT but we'll just let the RT win, it's more interesting.
  CONV_TYPES = [ ['a_mentions_b', 'me'], ['a_replies_b', 're'], ['a_retweets_b', 'rt'], ]

  def repair_conversation_json user_a_id, user_b_id, old_json
    begin
      oldhsh = JSON.load(old_json)
    rescue StandardError => e
      puts [old_json, e, e.backtrace].join("\t")
      warn [old_json, e, e.backtrace].join("\t")
      return
    end
    # {"b_retweets_a":[[7814238660]],"b_mentions_a":[[7814238660]]}
    convs_by_id = {}
    CONV_TYPES.each do |conv_type, conv_code|
      convs = oldhsh[conv_type] or next
      convs.each do |tw_id, in_re_tw_id|
        convs_by_id[tw_id] = [tw_id.to_i, conv_code, in_re_tw_id.to_i].reject{|x| x == 0}.compact
      end
    end
    conv_hsh = { "user_a_id" => user_a_id.to_i, "user_b_id" => user_b_id.to_i, "conversations" => convs_by_id.values.sort }
    conv_hsh.to_json unless convs_by_id.blank?
  end
end
Wukong::Script.new(
  BulkLoadConversation,
  nil,
  :map_speculative => "false",
  :max_maps_per_node => 2
  ).run
