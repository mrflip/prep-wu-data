#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'wuclan/twitter' ; include Wuclan::Twitter
require 'wuclan/twitter/twitter_user'

class LastSeenStateUniqer < Wukong::Streamer::UniqByLastReducer
  include Wukong::Streamer::StructRecordizer
  attr_accessor :uniquer_count

  def get_key obj, *_
    return obj if obj.is_a?(BadRecord)
    obj.key
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

if $0 == __FILE__
  Wukong::Script.new(
    nil,
    LastSeenStateUniqer,
    :map_command      => '/bin/cat',
    :partition_fields => 2,
    :sort_fields      => 3,
    ).run
end
