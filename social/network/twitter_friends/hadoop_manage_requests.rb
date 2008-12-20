#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'active_support'
require 'faster_csv'
require 'imw' ; include IMW
require 'hadoop_utils'; include HadoopUtils
# as_dset __FILE__
require 'twitter_flat_model'

module Mapper
  def self.load_line line
    line = line.chomp
    begin
      line.parse_tsv
    rescue
      warn "\n\n!!!!!!!Couldn't parse '#{line}'\n\n"
      []
    end
  end
  def self.emit_scrape_request thing, context, page
    out_key = [thing.screen_name, context, page].join('-')
    priority = "%06d" % [2000 - ((1+thing.followers_count.to_i) / 100.0).ceil]
    puts [out_key, 'scrape_request', thing.id, priority].to_tsv
  end

  def self.run_map
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
  end
end

module Reducer
  def self.load_line line
    line = line.chomp
    line.split "\t"
  end
  #
  # Emit the scrape request, along with its file (if scraped)
  # in the case there's no accompanying scrape request,
  # re-emit the file listing for retrial.
  #
  def self.emit_scrape_request parts
    if parts['scrape_request']
      item_key, id, priority           = parts['scrape_request']
      _, _,  _, _, size, scrape_session, scraped_at   = parts['scraped_file']
      screen_name, context, page = item_key.split('-')
      out_item_key = [id, context, page].join('-')
      out_context = parts['scraped_file'] ? 'scrape_request_done' : 'scrape_request'
      puts [out_context, priority, out_item_key, screen_name, context, page, id, size, scrape_session, scraped_at].join("\t")
    else
      puts ['scraped_file', *parts['scraped_file']].join("\t")
    end
  end

  def self.run_reduce
    parts = {}
    last_key = nil
    $stdin.each do |line|
      item_key, context, *vals = load_line line
      last_key ||= item_key
      # if we've seen the last record for this item_key,
      if last_key != item_key
        # dump it out
        emit_scrape_request parts
        # and get ready to hear about something new.
        parts = {}
        last_key = item_key
      end
      # remember what we're hearing.
      parts[context] = [item_key, *vals]
    end
  end
end


case ARGV[0]
when '--map'    then Mapper.run_map
when '--reduce' then Reducer.run_reduce
else raise "Need to specify an argument: --map, --reduce"
end
