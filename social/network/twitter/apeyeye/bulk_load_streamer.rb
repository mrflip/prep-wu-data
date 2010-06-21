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
      :user_ids        => 12001,
      :screen_names    => 12002,
      :search_ids      => 12003,
      :tweets_parsed   => 12004,
      :users_parsed    => 12005,
      #
      :tw_wordbag      => 14001,
      :tw_influence    => 14002,
      :tw_trstrank     => 14003,
      :tw_conversation => 14004,
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
  def initialize *args
    super *args
    @db = TokyoDbConnection::TyrantDb.new(('tw_'+options.dataset).to_sym)
    $stderr.puts @db
  end

  # Track progress regularly
  def log
    @log ||= PeriodicMonitor.new(options)
  end

  # notes each iteration
  def print_progress
    $stderr.puts log.progress(@db.size)
  end

  # track progress --
  def after_stream
    print_progress
  end
end
