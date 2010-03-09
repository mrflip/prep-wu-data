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

class MyspaceMoods < Wukong::Streamer::StructStreamer
  def process mood, *args, &block
    yield mood.inspect
  end
end

# This makes the script go.
Wukong::Script.new(MyspaceMoods, nil).run


