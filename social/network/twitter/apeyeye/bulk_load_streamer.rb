require 'rubygems'
require 'wukong'
require 'json'
require 'wukong/periodic_monitor'

Settings.define :dataset,    :required => true, :description => 'dataset to load, eg. trstrank, wordbag or influence'


module TokyoDbConnection
  class TyrantDb
    DB_SERVERS = [
        '10.194.101.156',
        '10.196.73.156',
        '10.196.75.47',
        '10.242.217.140',
    ].freeze

    DB_PORTS = {
      :screen_names    => 12002,
      :search_ids      => 12003,
      #
      :tw_user_info    => 14000,
      :tw_wordbag      => 14101,
      :tw_influence    => 14102,
      :tw_trstrank     => 14103,
      :tw_conversation => 14104,
      #
      :screen_names2   => 12004,
      :search_ids2     => 12005,
      #
      :tw_user_info2    => 14200,
      :tw_wordbag2      => 14201,
      :tw_influence2    => 14202,
      :tw_trstrank2     => 14203,
      :tw_conversation2 => 14204,
      :tw_strong_links2 => 14205,
      :tw_word_stats2   => 14206,
      #
      :ip_geo_census    => 14400,
    }

  end
end
require 'wukong/keystore/tyrant_db'

#
# Load precomputed json data into the ApeyEye database.
#
# See icsdata/social/network/twitter/apeyeye/bulk_load_generic.rb for an example
#
#
class BulkLoadStreamer < Wukong::Streamer::RecordStreamer
  # Track progress regularly
  def log
    @log ||= PeriodicMonitor.new(options)
  end

  # track progress --
  #
  # NOTE: emits to stdout, since other output is going to DB
  #
  def print_progress
    emit         log.progress(db.size)
    $stderr.puts log.progress(db.size)
  end

  # track progress --
  def after_stream
    print_progress
  end

  def db
    @db ||= TokyoDbConnection::TyrantDb.new(('tw_'+options.dataset).to_sym)
  end
end
