#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'json'
require 'cassandra' ; include Cassandra::Constants

# Settings.define :dataset,    :default => 'trstrank', :description => 'dataset to load, eg. trstrank, wordbag or influence'
Settings[:dataset] = 'wordbag'

#
# Load precomputed json data into the ApeyEye database.
#
#   ~/ics/icsdata/social/network/twitter/utils/apeyeye/bulk_loader.rb --dataset=influence --rm --run /data/sn/tw/fixd/apeyeye/influence/reply_json   /tmp/bulkload/influence
#   ~/ics/icsdata/social/network/twitter/utils/apeyeye/bulk_loader.rb --dataset=trstrank  --rm --run /data/sn/tw/fixd/apeyeye/trstrank/trstrank_json /tmp/bulkload/trstrank
#
#

class BulkLoader < Wukong::Streamer::RecordStreamer
  def initialize *args
    super *args
    # database connection
    @cassandra_db       = Cassandra.new('SocNetTw', %w[ 10.194.11.47 10.194.61.123 10.194.61.124 10.194.99.239 10.195.219.63 10.212.102.208 10.212.66.132 10.218.55.220 ].map{|s| "#{s}:9160"})
    @cf_for_user_id     = self.options.dataset+'_user_id'
    @iter = 0
  end

 
  def process token, user_id, num_user_tok_usages, tot_user_usages, user_tok_freq, vocab
    hsh = { :token => token, :id => user_id, :tok_usages => num_user_tok_usages, :tot_user_usages =>  }
    begin
      @cassandra_db.insert @cf_for_user_id,     user_id,     {'json' => json, 'screen_name' => screen_name }, :consistency => Cassandra::Consistency::ZERO unless user_id.blank?
    rescue RuntimeError => e ; warn "Insert failed: #{e}" end
    if (@iter+=1) % 10_000 == 0 then yield(json) ; $stderr.puts [@iter, screen_name, user_id, json].join("\t") end
  end
end

Wukong::Script.new( BulkLoader, nil ).run

# def each_record &block
#   @batch_size ||= options.batch_size.to_i
#   while ! $stdin.eof?
#     iter = 0
#     @cassandra_db.batch(:consistency => Cassandra::Consistency::ZERO) do
#       $stdin.each do |line|
#         yield line
#         break if (iter += 1) % @batch_size == 0
#       end
#     end
#     print "#{iter}\t"
#   end
# end
# Settings.define :batch_size, :default => 1000,       :description => 'How many records to batch into cassandra at a time'
