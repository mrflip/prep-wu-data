#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'

class LastSeenStateUniqer < Wukong::Streamer::UniqByLastReducer

  attr_accessor :uniquer_count

  def get_key *args
    user_id, screen_name, timestamp = args
    yield [user_id, screen_name, timestamp]
  end
  #
  # Adopt each value in turn: the last one's the one you want.
  #
  def accumulate obj, *_
    self.final_value = obj
  end

  #
  # Emit the last-seen value
  #
  def finalize
    yield final_value.to_flat if final_value
  end

end

Wukong::Script.new(
    nil,
    LastSeenStateUniqer,
    :map_command      => '/bin/cat',
    :partition_fields => 2,
    :sort_fields      => 3,
    :reduce_tasks     => 96
    ).run
end
