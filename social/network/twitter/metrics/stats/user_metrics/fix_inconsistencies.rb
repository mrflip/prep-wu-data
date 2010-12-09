#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'

class Reducer < Wukong::Streamer::UniqByLastReducer
  
  def get_key *args
    yield args[0..2]
  end

  def accumulate *args
    self.final_value = args
  end

  def finalize
    yield final_value.flatten if final_value
  end
  
end

Wukong::Script.new(
  nil,
  Reducer,
  :map_command => '/bin/cat',
  :partition_fields => 2,
  :sort_fields      => 3,
  :reduce_tasks     => 96
  ).run
