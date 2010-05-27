#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'wuclan/twitter'               ; include Wuclan::Twitter::Model
require 'wuclan/twitter/parse/cassandra_user_id_cache'

class UserIDMapper < Wukong::Streamer::StructStreamer
    include CassandraUserIDCache
  
  def initialize *args
    super *args
    @iter = 0
  end

  # just fill the db with triplets
  def process object, *_, &block
    user_id_data = {}
    user_id_data['user_id']     = object.id unless object.id.blank?
    user_id_data['search_id']   = object.sid unless object.sid.blank?
    user_id_data['screen_name'] = object.screen_name unless object.screen_name.blank?
    search_ids_insert(object.sid, user_id_data) unless object.sid.blank?
    api_ids_insert(object.id, user_id_data) unless object.id.blank?
    screen_names_insert(object.screen_name, user_id_data) unless object.screen_name.blank?
    if (@iter+=1) % 1000 == 0 then yield(object) ; $stderr.puts [@iter, object.to_flat].flatten.join("\t") end
  end
end

Wukong::Script.new(
  UserIDMapper,
  nil
  ).run
