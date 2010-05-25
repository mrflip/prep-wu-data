#!/usr/bin/env ruby
require 'wukong'
require 'wuclan/twitter'               ; include Wuclan::Twitter::Model
require File.dirname(__FILE__)+'/last_seen_state'

class UserIDMapper < Wukong::Streamer::StructStreamer
  include
end

Wukong::Script.new(
  UserIDMapper,
  nil
  ).run
