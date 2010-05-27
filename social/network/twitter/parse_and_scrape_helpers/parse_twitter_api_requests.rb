#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'monkeyshines'
require 'wuclan/twitter'        ; include Wuclan::Twitter::Model
require 'wuclan/twitter/parse'  ; include Wuclan::Twitter::Scrape
require 'wuclan/twitter/parse/conditional_twitter_emission'
# if you're anyone but original author this next require is useless but harmless.
require 'wuclan/twitter/scrape/old_skool_request_classes'
require File.dirname(__FILE__)+'/last_seen_state'

#
# Incoming objects are Wuclan::Twitter::Scrape requests.
#
# Their #parse method disgorges a stream of Wuclan::Twitter::Model objects, as
# few or as many as found.  For example, a twitter_user_request will assumedly
# have a twitter_user record if it is healthy, but may not have a tweet (if the
# user hasn't ever tweeted) and might not have profile or style info (if the
# user is protected).
#
class TwitterRequestParser < Wukong::Streamer::StructStreamer
  include ConditionalTwitterEmission
  def process request, *args, &block
    # return unless request.healthy?
    begin
      request.parse(*args) do |obj|
        yield obj
      end
    rescue StandardError => e
      $stderr.puts ["Bad request:", e.to_s, request.to_flat].join("\t")[0..3000]
    end
  end
end


if $0 == __FILE__
  # Go script go!
  Wukong::Script.new(
    TwitterRequestParser,
    nil,
    :partition_fields => 2,
    :sort_fields      => 3,
    :reuse_jvms       => true
    ).run
end
