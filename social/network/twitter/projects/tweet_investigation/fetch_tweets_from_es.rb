#!/usr/bin/env jruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'uri'
require 'net/http/persistent'
require 'swineherd'
require 'configliere' ; Settings.use(:commandline, :env_var, :define)

Settings.define :user_ids,       :description => "Path to a file containing user ids"
Settings.define :host,      :default => 'http://10.118.243.184:9200', :description => "Elasticsearch host and port"
Settings.resolve!

#
# A dead simple, no nonsense, client class for talking to elasticsearch
#
class ElasticSearchClient

  attr_accessor :connection, :host

  def initialize host
    self.host       = URI.parse(host)
    self.connection = Net::HTTP::Persistent.new
  end

  def sanitize_string string
    #'u' option forces UTF-8 mode, which allows the regexp to grab the two
    #bytes required for characters outside the ASCII range,  like 'í'
    string.to_s.gsub(/[^\-:\w\.@#\*]+/u,' ')
  end

  def query_fields options
    if options[:query_fields]
      fields = options[:query_fields].map { |f| %Q{"#{f}"}}.inspect
      %Q{ "default_fields": #{fields} }
    else
      default_field = (options[:default_field] || "_all")
      %Q{ "default_field": "#{default_field}" }
    end
  end


  def path index_name, obj_type, action
    "/#{index_name}/#{obj_type}/#{action}"
  end

  def search index_name, obj_type, str, options={}

    action     = "_search"
    analyzer   = "standard"
    operator   = "AND"
    from       = (options[:from]  || 0)
    size       = (options[:limit] || 100)

    query_path      = path(index_name, obj_type, action)
    fields_to_query = query_fields(options)
    sanitized       = sanitize_string(str)
    request         = construct_request(query_path, sanitized, {:fields => fields_to_query, :analyzer => analyzer, :operator => operator, :from => from, :size => size})
    results         = execute_request(request)
    return results

  end

  #
  # This is wildly unsafe
  #
  def construct_request query_path, str, options
    Net::HTTP::Get.new(query_path).tap do |get|
      get.body = %Q{ {"query": {"query_string": { "query" :"#{str}", #{options[:fields]}, "default_operator" : "#{options[:operator]}" ,"analyzer" : "#{options[:analyzer]}"} }, "from": #{options[:from]}, "size": #{options[:size]} }}
    end
  end

  def execute_request request
    response = connection.request(host, request)
    response.body
  end
end

hdfs      = Swineherd::FileSystem.get :hdfs
client    = ElasticSearchClient.new(Settings.host)
indexes   = 'tweet-2009q3pre,tweet-2009q4,tweet-2010q1,tweet-201004,tweet-201005,tweet-201006,tweet-201007,tweet-201008,tweet-201009,tweet-201010,tweet-201011,tweet-201012,tweet-201101,tweet-201102'
user_ids  = hdfs.open(Settings.user_ids, 'r')
user_id   = user_ids.readline.strip.split("\t").first
p client.search(indexes, "tweet", "user_id:#{user_id}") 
