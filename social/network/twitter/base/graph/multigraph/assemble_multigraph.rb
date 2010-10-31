#!/usr/bin/env ruby
require 'rubygems'
require 'extlib/class'
require 'wukong'
require 'wuclan/twitter' ; include Wuclan::Twitter
require 'wuclan/twitter/a_relationships_b'

#
# Defines an edge in the twitter multigraph
#
class MultigraphEdge < Struct.new(:user_a, :user_b, :fo_i, :fo_o, :me_i, :me_o, :re_i, :re_o, :rt_i, :rt_o)

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

  def edge_weights
    [ a_follows_b? ? 1 : 0, b_follows_a? ? 1 : 0,
      me_o.length, me_i.length,
      re_o.length, re_i.length,
      rt_o.length, rt_i.length,
    ]
  end

end

#
# Implicitly expects [a_follows_b, a_atsigns_b]
#
class MultigraphMapper < Wukong::Streamer::StructStreamer
  def process rel, *_
    if rel.is_a?(AFollowsB)
      yield [rel.user_b_id, rel.user_a_id, "fo_i", 1]
      yield [rel.user_a_id, rel.user_b_id, "fo_o", 1]
    else
      yield [rel.user_b_id, rel.user_a_id, "#{rel.rel_type}_i", rel.tweet_id]
      yield [rel.user_a_id, rel.user_b_id, "#{rel.rel_type}_o", rel.tweet_id]
    end
  end
end

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
  end

  def edge_weights
    [ 'multi_edge', edge.user_a, edge.user_b, edge.edge_weights ]
  end

  def finalize_inner
    yield edge_weights
  end

end

Wukong::Script.new(
  MultigraphMapper,
  MultigraphReducer,
  :partition_fields  => 2,
  :sort_fields       => 2,
  :io_record_percent => 0.3,
  :map_speculative   => "true",
  :reduce_tasks      => 60
  ).run
