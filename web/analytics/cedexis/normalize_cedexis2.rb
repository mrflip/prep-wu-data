#! /usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'json'

class Mapper < Wukong::Streamer::RecordStreamer

  def recordize str
    words = str.split(",")
    words
  end

  def process date, market_id, market_label, country_id, country_label, network_id, network_label, provider_id, provider_label, probe_id,probe_label, count, score, *_
    row_key = [ provider_label, market_label, country_label, network_label ].map  { |entry| entry.strip.gsub(/\s/, '_').gsub(/\W/, '') }.join(":").downcase
    col_fam = probe_label.gsub(/\s/, '_').downcase
    col_nam = Time.parse(date).to_flat
    col_val = { 'count' => count, 'score' => score }.to_json
    yield [ row_key, col_fam, col_nam, col_val ]
  end

end

Wukong::Script.new(Mapper, nil).run
