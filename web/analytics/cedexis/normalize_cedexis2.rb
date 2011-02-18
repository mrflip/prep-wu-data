#! /usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'json'

class Mapper < Wukong::Streamer::RecordStreamer

  def recordize str
    fields = str.strip.split(",")
    fields if fields.size == 13
  end

  def process date, market_id, market_label, country_id, country_label, network_id, network_label, provider_id, provider_label, probe_id, probe_label, count, score
    row_key = [ provider_label, market_label, country_label, network_label ].map  { |entry| entry.strip.gsub(/\s/, '_').gsub(/[^\w\.]/, '') }.join(":").downcase
    col_fam = probe_label.gsub(/\s/, '_').downcase
    date_long = Time.parse(date).to_flat
    yield [ row_key, col_fam, 'count', count, date_long ]
    yield [ row_key, col_fam, 'score', score, date_long ]
  end

end

Wukong::Script.new(Mapper, nil).run
