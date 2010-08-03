#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'json'
require 'wukong/periodic_monitor'
require File.dirname(__FILE__)+'/geo_ip_census' ; include GeoIPCensus

Settings.define :dataset,    :required => true, :default => 'ip_geo_census'


module TokyoDbConnection
  class TyrantDb
    DB_SERVERS = [
        '10.194.101.156',
        '10.196.73.156',
        '10.196.75.47',
        '10.242.217.140',
    ].freeze

    DB_PORTS = {
      :tw_screen_names  => 12002,
      :tw_search_ids    => 12003,
      #
      :tw_user_info     => 14000,
      :tw_wordbag       => 14101,
      :tw_influence     => 14102,
      :tw_trstrank      => 14103,
      :tw_conversation  => 14104,
      #
      :tw_screen_names2 => 12004,
      :tw_search_ids2   => 12005,
      #
      :tw_user_info2    => 14200,
      :tw_wordbag2      => 14201,
      :tw_influence2    => 14202,
      :tw_trstrank2     => 14203,
      :tw_conversation2 => 14204,
      :tw_strong_links2 => 14205,
      :tw_word_stats2   => 14210,
      #
      :ip_geo_census    => 14400,
    }

  end
end
require 'wukong/keystore/tyrant_db'

# cat ip_geo_census_matched.tsv | ~/ics/icsdata/web/analytics/parse_ipv4_geo_ip_census.rb --map > ip_geo_census_24_blocks.tsv
#

class Mapper < Wukong::Streamer::LineStreamer
  def process line, &blk
    fields = line.chomp.gsub(/\"/, "").split("\t") rescue []
    ip_bot, ip_top, ip_dotted_bot, ip_dotted_top, *census_fields = fields
    census_fields.delete_at(1) # extra zip code column
    #
    census_record = RawIPCensus.new(*census_fields)
    ip_block = IpBlock.new(ip_bot, ip_top, census_record)
    ip_block.ip_24_blocks do |ip_head, bot_tail, top_tail|
      dotted_24 = [ip_head >> 16, (ip_head >> 8) % 256, ip_head % 256].join('.')
      yield [dotted_24, "%03d" % top_tail,
        # dotted_bot, census_record.to_a.join(",")
        ip_block.census_record.to_hash.compact_blank.to_json
      ]
    end
  end
end

class Reducer < Wukong::Streamer::AccumulatingReducer
  def get_key ip_24, *args
    ip_24
  end

  def start! ip_24, *args
    @records = []
  end

  def accumulate ip_24, ip_tail_top, json
    @records << [ip_tail_top.to_i, json]
  end

  def finalize
    ip_tail_to_json = @records.sort.map{|ip_tail, json| [ip_tail, json].join(",")}
    yield [ key, ip_tail_to_json ]
    db.insert(key, ip_tail_to_json)
    log.periodically{ print_progress(key, ip_tail_to_json) }
  end

  # track progress --
  #
  # NOTE: emits to stdout, since other output is going to DB
  #
  def print_progress *args
    Log.info log.progress(db.size, *args)
  end
  # Used to log progress periodically
  def log
    @log ||= PeriodicMonitor.new(options)
  end
  # track progress --
  def after_stream
    print_progress
  end
  def db
    @db ||= TokyoDbConnection::TyrantDb.new(:ip_geo_census)
  end

end

Wukong::Script.new(Mapper, Reducer).run
