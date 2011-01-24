#!/usr/bin/env ruby

require 'rubygems'
require 'configliere'
require 'uri'
require 'net/http/persistent'
require 'json'

def internal_ip
  `hostname -i`.chomp
end

def default_host
  "#{internal_ip}:9200"
end

Settings.use :commandline
Settings.define :host, :description => "ElasticSearch host (& port) to send requests to", :default => default_host
Settings.define :indices, :description => "(Comma-separated) indices to query", :default => "tweet-2009q3pre,tweet-2009q4,tweet-2010q1,tweet-201004,tweet-201005,tweet-201006,tweet-201007,tweet-201008,tweet-201009,tweet-201010,tweet-201011"
Settings.define :type, :description => "The type to seaerch", :default => "tweet"
Settings.define :size, :description => "Number of hits in each query", :default => 100, :type => Integer
Settings.define :max, :description => "Max number of hits to return", :type => Integer
Settings.define :verbose, :description => "Be verbose", :type => :boolean, :flag => :v
Settings.resolve!

def connection
  @connection ||= Net::HTTP::Persistent.new
end

def host
  @host ||= URI.parse("http://#{Settings[:host]}")
end

def path
  @path ||= "/#{Settings[:indices]}/#{Settings[:type]}/_search"
end

def query_body
  Settings.rest.first
end

def request_body from=0
  %Q!{"query": #{Settings.rest.first}, "size": #{Settings[:size]}, "from": #{from}}!
end

def elasticsearch_response from=0
  get = Net::HTTP::Get.new(path)
  get.body = request_body(from)
  connection.request(host, get)
end

def elasticsearch_result from=0
  response = elasticsearch_response(from)
  JSON.parse(response.body)
end

def total_hits
  Settings[:max] || elasticsearch_result['hits']['total'].to_i
end

def to_tsv from, &block
  elasticsearch_result(from)['hits']['hits'].each do |hit|
    tweet = hit['_source']
    yield [tweet['tweet_id'], tweet['created_at'], tweet['user_id'], tweet['screen_name'], tweet['in_reply_to_user_id'], tweet['in_reply_to_status_id'], tweet['text'], tweet['source']].map(&:to_s).join("\t")
  end
end

def loop
  began = Time.now
  total = total_hits
  $stderr.puts "Looping over #{total} hits..." if Settings[:verbose]
  from  = 0
  while from <= total
    $stderr.puts "Querying starting from hit #{from}..." if Settings[:verbose]
    to_tsv(from) do |row|
      puts row
    end
    from += Settings[:size]
  end
  ended = Time.now
  minutes = (ended - began) / 60.0
  $stderr.puts "Completed in #{minutes} minutes"
end

def validate_query_body!
  Settings.die("Must give a JSON query body to execute!") if query_body.blank?
  begin
    JSON.parse(query_body)
  rescue JSON::ParserError => e
    puts e.message
    Settings.die("Malformed JSON")
  end
end

if $0 == __FILE__
  validate_query_body!
  loop
end
