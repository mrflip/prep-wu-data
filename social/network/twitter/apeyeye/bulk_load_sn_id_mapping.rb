#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/bulk_load_streamer'


Settings.dataset = 'user_info2'

class BulkLoadJsonAttribute < BulkLoadStreamer
  
  def process *args
    uid, sn = [args[1],args[3]]
    return if sn.blank? || uid.blank?
    db.insert(sn.downcase, uid)
    log.periodically{ print_progress }
  end

  def db
    @db ||= TokyoDbConnection::TyrantDb.new(('tw_'+options.dataset).to_sym)
  end

  # track progress --
  #
  # NOTE: emits to stdout, since other output is going to DB
  #
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
