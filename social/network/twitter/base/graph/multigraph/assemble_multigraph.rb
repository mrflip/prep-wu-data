#!/usr/bin/env ruby
require 'rubygems'
require 'extlib/class'
require 'wukong'
require 'wuclan/twitter'
require 'wuclan/twitter/model'               ; include Wuclan::Twitter::Model
require 'json'

Settings.define :emit_type,   :default => "edge_weights", :type => String, :description => 'Type of thing to emit'

class MultigraphMapper < Wukong::Streamer::StructStreamer
  def process thing, *_
    case thing
    when AFollowsB
      yield [thing.user_b_id, thing.user_a_id, 'fo_i', 1]
      yield [thing.user_a_id, thing.user_b_id, 'fo_o', 1]
    when AAtsignsB
      yield [thing.user_b_id, thing.user_a_id, 'at_i', thing.tweet_id]
      yield [thing.user_a_id, thing.user_b_id, 'at_o', thing.tweet_id]
    when ARepliesB
      yield [thing.user_b_id, thing.user_a_id, 're_i', thing.tweet_id, thing.in_reply_to_tweet_id]
      yield [thing.user_a_id, thing.user_b_id, 're_o', thing.tweet_id, thing.in_reply_to_tweet_id]
    when ARetweetsB
      yield [thing.user_b_id, thing.user_a_id, 'rt_i', thing.tweet_id]
      yield [thing.user_a_id, thing.user_b_id, 'rt_o', thing.tweet_id]
    when TwitterUserId
      yield [thing.user_id, '!u'] # , thing.tweets_per_day]
    end
  end
end


class MultigraphEdge < Struct.new(:user_a, :user_b, :fo_i, :fo_o, :at_i, :at_o, :re_i, :re_o, :rt_i, :rt_o, :tw_i_d)
  EDGE_WEIGHT_FO = 1
  EDGE_WEIGHT_SY = 1
  EDGE_WEIGHT_AT = 1
  EDGE_WEIGHT_RE = 0
  EDGE_WEIGHT_RT = 0.5

  def initialize *args
    super *args
    members.each{|k| self[k] ||= [] }
  end


  def a_follows_b?
    (fo_o.flatten.first.to_s == '1' ? true : nil)
  end

  def b_follows_a?
    (fo_i.flatten.first.to_s == '1' ? true : nil)
  end

  # def adopt_tweet_rel rel, *attrs
  #   tw_id, in_re_tw_id = attrs.reject(&:blank?).map(&:to_i)
  #   case rel
  #   when
  #   end
  # end

  def edge_weights
    [ a_follows_b? ? 1 : 0, b_follows_a? ? 1 : 0,
      at_o.length, at_i.length,
      re_o.length, re_i.length,
      rt_o.length, rt_i.length,
    ]
  end

  #
  # Arbitrary
  #
  def combined_edge_weight
    a = [
      ( (a_follows_b? ? EDGE_WEIGHT_FO : 0)       +
        (EDGE_WEIGHT_AT * Math.sqrt(at_o.length)) +
        (EDGE_WEIGHT_RT * Math.sqrt(rt_o.length))
        ),
      ( (b_follows_a? ? EDGE_WEIGHT_FO : 0)       +
        (EDGE_WEIGHT_AT * Math.sqrt(at_i.length)) +
        (EDGE_WEIGHT_RT * Math.sqrt(rt_i.length))
        )
    ]
    a.inject(0.0){|avg,x| avg += x; avg / a.size.to_f}
  end

end

#
# This reducer does a double group:
# It receives a stream
#
#     key_a    key_b    [...stuff...]
#
# For example
#
#     bob      sally    fo
#     bob      sally    re     1234
#     bob      jane     fo
#
# Acting as an accumulating reducer, it takes by default the first field as key
# and calls
#   start_outer(*first_record) with the first record having key_a
#   start_inner(*first_record) with the first record having [key_a key_b]
#   accumulate                 with every record
#   finalize_inner             after the last record having [key_a key_b]
#   finalize_outer             after the last record having key_a
#
#
class Wukong::Streamer::EdgeGroupReducer < Wukong::Streamer::AccumulatingReducer
  def get_key key_a, key_b, *_
    [key_a, key_b]
  end
  def start! *args, &block
    start_inner *args, &block
  end

  def finalize *args, &block
    finalize_inner *args, &block
  end
end

class MultigraphReducer < Wukong::Streamer::EdgeGroupReducer
  attr_accessor :edge

  def start! user_a, user_b, *_
    self.edge = MultigraphEdge.new(user_a, user_b)
  end

  def accumulate user_a, user_b, rel, *attrs
    self.edge[rel] << attrs.reject(&:blank?).map(&:to_i)
    # case rel
    # when 'foi', 'foo'
    # else
    #   self.edge.adopt_tweet_rel rel, *attrs
    # end
  end

  def json_for_conversation
    [edge.user_a, edge.user_b, {
        :a_follows_b  => edge.a_follows_b?, :b_follows_a  => edge.b_follows_a?,
        :a_mentions_b => edge.at_o.uniq,    :b_mentions_a => edge.at_i.uniq,
        :a_retweets_b => edge.rt_o.uniq,    :b_retweets_a => edge.rt_i.uniq,
        :a_replies_b  => edge.re_o.uniq,    :b_replies_a  => edge.re_i.uniq,
      }.reject{|k,v| v.blank? }.to_json
      ]
  end

  def edge_weights
    [ 'multi_edge', edge.user_a, edge.user_b, edge.edge_weights ]
  end

  def finalize_inner
    case options.emit_type
    when "edge_weights" then
      yield edge_weights
    when "conversations" then
      yield json_for_conversation
    when "combined_weights" then
      yield [ edge.user_a, edge.user_b, edge.combined_edge_weight ]
    end
  end
end

Wukong::Script.new(
  MultigraphMapper,
  MultigraphReducer,
  :partition_fields => 1,
  :sort_fields      => 2,
  :io_record_percent => 0.3,
  :map_speculative => "false"
  ).run
