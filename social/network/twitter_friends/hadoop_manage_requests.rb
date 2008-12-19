#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'active_support'
require 'faster_csv'
require 'imw' ; include IMW
require 'hadoop_utils'; include HadoopUtils
# as_dset __FILE__
require 'twitter_flat_model'

def load_line line
  line = line.chomp
  begin
    line.parse_tsv
  rescue
    warn "\n\n!!!!!!!Couldn't parse '#{line}'\n\n"
    []
  end
end



def emit_scrape_request thing, context, page
  out_key = [thing.screen_name, context, page].join('-')
  priority = "%06d" % [2000 - ((1+thing.followers_count.to_i) / 100.0).ceil]
  puts [out_key, 'scrape_request', thing.id, priority].to_tsv
end

last_user_id = nil
$stdin.each do |line|
  key, item_key, *vals = load_line line
  next unless key
  klass = key.to_s.camelize.constantize
  #p [key, klass, klass.members, vals[0..(klass.members.length-1)]]

  thing = klass.new(*vals[0..(klass.members.length-1)])
  case thing
  when TwitterUser, TwitterUserPartial
    next if thing.id == last_user_id
    last_user_id = thing.id
    (1 .. ((1+thing.followers_count.to_i) / 100.0).ceil).each do |page| emit_scrape_request(thing, :followers, page) end
    (1 .. ((1+thing.friends_count.to_i)   / 100.0).ceil).each do |page| emit_scrape_request(thing, :friends,   page) end if thing.is_a?(TwitterUser)
    emit_scrape_request thing, :user, 1
  when ScrapedFile
    puts [item_key, 'scraped_file', thing.screen_name, thing.context, thing.page,
       thing.size, thing.scrape_session, thing.scraped_at ].to_tsv
  else
    raise "Don't know what to do with '#{key}'"
  end
end

