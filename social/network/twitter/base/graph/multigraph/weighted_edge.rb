#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require File.dirname(__FILE__)+'/multiedge.rb'

class EdgeWeightMapper < Wukong::Streamer::StructStreamer
  def process edge, *_
    # eg: 12345     940110     1     0     0.3
    yield [edge.user_a_id, edge.user_b_id, edge.fo_sy, edge.at_sy, edge.weight] if edge.weight > 0.0
  end
end

Wukong::Script.new(EdgeWeightMapper, nil).run
