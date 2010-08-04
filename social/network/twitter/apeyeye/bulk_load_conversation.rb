#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/bulk_load_streamer'

Settings.dataset = 'conversation2'

#
# Load precomputed json data into the ApeyEye database.
#
#   ~/ics/icsdata/social/network/twitter/apeyeye/bulk_load_conversation.rb --rm --run --log_interval=10000  s3n://infochimps-data/data/soc/net/tw/pkgd/conversation_json_20100729   /tmp/bulkload/conversation
#
class BulkLoadConversation < BulkLoadStreamer

  def process  user_a_id, user_b_id, conversation_json
    return if [conversation_json, user_a_id, user_b_id].any?(&:blank?)
    conversation_json = repair_conversation_json(user_a_id, user_b_id, conversation_json) or return
    db.insert("#{user_a_id}:#{user_b_id}", conversation_json)
    log.periodically{ print_progress(user_a_id, user_b_id, conversation_json) }
  end

  # !! IMPORTANT !!
  # The order here is important, since we want me to lose to rt and re.
  # An RE should never also be an RT but we'll just let the RT win, it's more interesting.
  CONV_TYPES = [ ['a_mentions_b', 'me'], ['a_replies_b', 're'], ['a_retweets_b', 'rt'], ]

  # marge different types of @mention
  #
  # @example
  #    1234  2345 {"b_retweets_a":[[7814238660]],"b_mentions_a":[[7814238660]]}
  #
  def repair_conversation_json user_a_id, user_b_id, old_json
    oldhsh = safely_parse_json(old_json)
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
