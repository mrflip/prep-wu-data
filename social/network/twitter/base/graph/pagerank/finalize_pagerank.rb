#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'wukong/keystore/tyrant_db' ; include TokyoDbConnection

USER_ID_DB = TyrantDb.new(:user_ids)

class Mapper < Wukong::Streamer::RecordStreamer

  def process user_a, rank, list, &blk
    yield [user_a, get_screen_name(user_a), rank]
  end

  def get_screen_name user_id
    return if user_id.blank?
    USER_ID_DB.get(user_id.to_s)
  end

end

Wukong::Script.new(Mapper, nil).run
