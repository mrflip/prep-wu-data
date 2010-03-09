#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'crack'
require 'wuclan/myspace';
require 'wuclan/myspace/raw';
require 'wuclan/myspace/model';
require 'wuclan/myspace/parser'
include Wuclan::Myspace::Raw
include Wuclan::Myspace::Model
include Wuclan::Myspace::Parser
include Wuclan::Myspace::Model::RawEntryCategoryToModel

#Script for spitting out stuff about local places
class MyspaceUrl < Wukong::Streamer::StructStreamer
  def process activity, *args, &block
    return unless activity.respond_to?(:shared_url)
    yield [ activity.shared_url, activity.to_flat ].flatten
  end
end

# This makes the script go.
Wukong::Script.new(
  MyspaceUrl,
  nil,
  :partition_fields => 1,
  :sort_fields      => 1,
  :reduce_command => %Q{ /usr/bin/cut -d"\t" -f2- }
  ).run
