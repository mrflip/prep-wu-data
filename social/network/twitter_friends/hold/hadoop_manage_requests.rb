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

  #
  # Scrape request
  #   screen_name-context-page  scrape_request  id      priority
  #
  def self.emit_scrape_request twitter_user, context, page
    out_key = [twitter_user.screen_name, context, page].join('-')
    priority = "%06d" % [2000 - ((1+twitter_user.followers_count.to_i) / 100.0).ceil]
    puts [out_key, 'scrape_request', twitter_user.id, priority].to_tsv
  end

  #
  # Scraped file
  #   screen_name-context-page  scraped_file scraped_at ...values....
  #
  def self.emit_scraped_file item_key, vals
    puts [item_key, 'scraped_file', *vals].to_tsv
  end

  def self.run_map
    last_user_id = nil
    $stdin.each do |line|
      # Grok line
      key, item_key, *vals = load_line line ; next unless key
      #
      case key.to_sym
      when :twitter_user, :twitter_user_partial
        # Instantiate object
        klass = key.to_s.camelize.constantize
        twitter_user = klass.new(*vals.compact)
        next unless twitter_user.screen_name =~ /\A\w+\z/
        #
        # Skip duplicates
        next if twitter_user.id == last_user_id
        last_user_id = twitter_user.id
        #
        # Tell about self, and one page per hundred followers, and one per hundred friends
        emit_scrape_request twitter_user, :user, 1
        (1 .. ((1+twitter_user.followers_count.to_i) / 100.0).ceil).each do |page| emit_scrape_request(twitter_user, :followers, page) end
        (1 .. ((1+twitter_user.friends_count.to_i)   / 100.0).ceil).each do |page| emit_scrape_request(twitter_user, :friends,   page) end if twitter_user.is_a?(TwitterUser)
      when :scraped_file
        # re-emit the file
        emit_scraped_file   item_key, vals
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
      # grok
      item_key, id, priority                         = parts['scrape_request']
      _, scraped_at, _, _, _, size, scrape_session   = parts['scraped_file']
      screen_name, context, page = item_key.split('-')
      # categorize
      out_context = "%s-%s" % [ (parts['scraped_file'] ? 'scrape_request_done' : 'scrape_request'), context ]
      # emit
      puts [out_context, context, priority, id, page, screen_name, size, scrape_session, scraped_at].join("\t")
    else
      # grok
      item_key, scraped_file_attrs = parts['scrape_request']
      # emit
      puts ['scraped_file', *scraped_file_attrs].join("\t")
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
        emit_scrape_request parts       # dump it out
        parts = {}                      # and get ready to hear about something new.
        last_key = item_key
      end
      # Otherwise keep this one
      parts[context] = [item_key, *vals]
    end
  end
end


case ARGV[0]
when '--map'    then Mapper.run_map
when '--reduce' then Reducer.run_reduce
else raise "Need to specify an argument: --map, --reduce"
end
