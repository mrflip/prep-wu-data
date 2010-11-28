#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'

class Mapper < Wukong::Streamer::RecordStreamer
  def process *args
    return unless args.length == 3
    yield args[1..-1]
  end
end

class Reducer < Wukong::Streamer::AccumulatingReducer
  attr_accessor :adj_list
  def start! user_a_id, user_b_id
    self.adj_list = []
  end

  def accumulate user_a_id, user_b_id
    self.adj_list << user_b_id
  end

  def finalize
    yield [key, adj_list].flatten
  end
end


Wukong::Script.new(Mapper, Reducer, :reduce_tasks => '20').run
