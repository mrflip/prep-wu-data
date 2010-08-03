#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require File.dirname(__FILE__)+'/bulk_load_streamer'

#
# to_i's on user ids
# make sure I'm not my own best friend
#

class BulkLoadJsonAttribute < BulkLoadStreamer
  def process user_id, json
    return if json.blank? || user_id.blank?
    db.insert(user_id, fix_json(json))
    log.periodically{ print_progress }
  end

  def db
    @db ||= TokyoDbConnection::TyrantDb.new(('tw_'+options.dataset).to_sym)
  end

  def fix_json json_string
    hsh = JSON.parse(json_string)
    hsh["user_id"] = hsh["user_id"].to_i
    hsh["strong_links"].map!{|pair| pair = [pair["user_id"].to_i, pair["weight"].to_f]; pair[1] = 0.05 if pair.last == 0.0; pair }.reject{|x| x.first == hsh["user_id"]} unless hsh["strong_links"].blank?
    hsh.to_json
  end
  
  def print_progress
    emit         log.progress(db.size)
    $stderr.puts log.progress(db.size)
  end
end
Wukong::Script.new(
  BulkLoadJsonAttribute,
  nil,
  :map_speculative => "false",
  :max_maps_per_node => 2
  ).run
