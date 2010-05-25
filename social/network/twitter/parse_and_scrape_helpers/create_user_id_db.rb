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

  def process object, *_, &block
    user_id_triplet = {'api_id' => object.id, 'search_id' => object.sid, 'screen_name' => object.screen_name}
    insert_search_id(object.sid, user_id_triplet) unless object.sid.blank?
    insert_api_id(object.id, user_id_triplet) unless object.id.blank?
    insert_screen_name(object.screen_name, user_id_triplet) unless object.screen_name.blank?
    if (@iter+=1) % 1000 == 0 then yield(object) ; $stderr.puts [@iter, object.to_flat].flatten.join("\t") end
  end
end

Wukong::Script.new(
  UserIDMapper,
  nil
  ).run
