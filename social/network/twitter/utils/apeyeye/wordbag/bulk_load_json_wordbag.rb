#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'wukong/encoding'
require 'json'
require 'cassandra' ; include Cassandra::Constants

LOGGING_INTERVAL = 10_000

#
# Compute wordbag json on the fly and dump into Apeyeye database
#
#   ./bulk_load_json_wordbag.rb --rm --run /data/sn/tw/fixd/word/user_word_bag_with_stats /tmp/bulkload/word_bag_with_stats_json
#
#
class BulkLoaderMapper < Wukong::Streamer::RecordStreamer
  def process(tok, user_id,
      num_user_tok_usages, tot_user_usages, user_tok_freq_ppb, vocab,
      tot_tok_usages, range, user_freq_avg, user_freq_stdev, global_freq_avg, global_freq_stdev, dispersion, tok_freq_ppb, &block)
    yield [user_id, vocab, tot_user_usages, tok, user_tok_freq_ppb, tok_freq_ppb ]
  end
end

class BulkLoaderReducer < Wukong::Streamer::AccumulatingReducer
  attr_accessor :user_id, :vocab, :tot_user_usages, :wordbag
  MAX_WORDBAG_SIZE = 100

  def initialize *args
    super *args
    5.times do
      begin
        @cassandra_db = Cassandra.new('SocNetTw', %w[ 10.194.11.47 10.194.61.123 10.194.61.124 10.194.99.239 10.195.219.63 10.212.102.208 10.212.66.132 10.218.55.220 ].map{|s| "#{s}:9160"})
      rescue StandardError => e
        warn "Couldn't connect to cassandra db: #{e} #{e.backtrace}"
        puts "Couldn't connect to cassandra db: #{e} #{e.backtrace}"
      end
      break if @cassandra_db
    end
    @iter = 0
  end

  def start! user_id, vocab, tot_user_usages, *args
    self.user_id = user_id
    self.vocab   = vocab.to_i
    self.tot_user_usages = tot_user_usages.to_i
    self.wordbag = []
  end

  def accumulate user_id, vocab, tot_user_usages, tok, user_tok_freq_ppb, tok_freq_ppb
    self.wordbag <<  { :tok => tok.wukong_decode, :user_freq_ppb => user_tok_freq_ppb.to_f, :rel_freq => (user_tok_freq_ppb.to_f / tok_freq_ppb.to_f) }
  end

  def insert_into_db screen_name_or_user_id, json
    screen_name_or_user_id.downcase!
    @cf_key = 'wordbag_'+((screen_name_or_user_id =~ /^\d+$/) ? 'user_id' : 'screen_name')
    begin
      @cassandra_db.insert @cf_key, screen_name_or_user_id, {'json' => json}, :consistency => Cassandra::Consistency::ONE unless screen_name_or_user_id.blank?
    rescue StandardError => e
      warn "Insert failed for #{screen_name_or_user_id} with #{json}: #{e}"
      puts "Insert failed for #{screen_name_or_user_id} with #{json}: #{e}"
    end
    if (@iter+=1) % LOGGING_INTERVAL == 0 then yield(json) ; $stderr.puts [@iter, screen_name_or_user_id, json].join("\t") end
  end

  def finalize
    wordbag.sort!{|a, b| b[:rel_freq] <=> a[:rel_freq] }
    json_hsh = { "vocab" => vocab, "total_usages" => tot_user_usages, "toks" => wordbag[0 ... MAX_WORDBAG_SIZE] }
    insert_into_db(user_id, json_hsh.to_json)
  end
end

Wukong::Script.new( BulkLoaderMapper, BulkLoaderReducer ).run
