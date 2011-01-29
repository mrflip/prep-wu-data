#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'wuclan/twitter' ; include Wuclan::Twitter
require 'wuclan/twitter/a_relationships_b'

#
# Defines an edge in the twitter multigraph
#
class MultigraphEdge < Struct.new(:user_a, :user_b, :fo_i, :fo_o, :me_i, :me_o, :re_i, :re_o, :rt_i, :rt_o)

  def initialize *args
    super *args
    members.each{|k| self[k] ||= 0 }
  end

  def a_follows_b?
    (fo_o != 0 ? true : nil)
  end

  def b_follows_a?
    (fo_i != 0 ? true : nil)
  end

  def edge_weights
    [ a_follows_b? ? 1 : 0, b_follows_a? ? 1 : 0,
      me_o, me_i, re_o, re_i, rt_o, rt_i,
    ]
  end

end

class MultigraphMapper < Wukong::Streamer::RecordStreamer
  def process *args
    if args.first == 'a_follows_b'
      return unless args.length == 3
      rsrc, user_a, user_b = args
      yield [user_b, user_a, "fo_i"]
      yield [user_a, user_b, "fo_o"]
    else
      return unless args.length == 7
      rsrc, user_a, user_b, rel = args
      yield [user_b, user_a, "#{rel}_i"]
      yield [user_a, user_b, "#{rel}_o"]
    end
  end
end

class MultigraphReducer < Wukong::Streamer::AccumulatingReducer
  attr_accessor :edge

  def get_key user_a, user_b, *_
    [user_a, user_b]
  end

  def start! user_a, user_b, *_
    self.edge = MultigraphEdge.new(user_a, user_b)
  end

  def accumulate user_a, user_b, rel, *_
    self.edge[rel] += 1
  end

  def finalize
    yield [ 'multi_edge', edge.user_a, edge.user_b, edge.edge_weights ]
  end

end

Wukong::Script.new(
  MultigraphMapper,
  MultigraphReducer,
  :partition_fields  => 2,
  :sort_fields       => 2,
  :io_record_percent => 0.3,
  :map_speculative   => "true",
  :reduce_tasks      => 120
  ).run
