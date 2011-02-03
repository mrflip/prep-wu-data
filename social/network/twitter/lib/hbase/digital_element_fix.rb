#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'configliere'

Settings.define :column_family
Settings.resolve!

class Mapper < Wukong::Streamer::RecordStreamer
  def process row_key, *args
    args.each do |col|
      col_name, col_value = col.split(",", 2)
      yield [row_key, Settings.column_family, col_name, col_value]
    end
  end
end

Wukong::Script.new(Mapper, nil).run

# This script needs to be implemented within the digital element hackbox output
