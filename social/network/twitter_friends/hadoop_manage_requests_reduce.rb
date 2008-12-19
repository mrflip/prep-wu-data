#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

def load_line line
  line = line.chomp
  line.split "\t"
end

#
# Emit the scrape request, along with its file (if scraped)
# in the case there's no accompanying scrape request,
# re-emit the file listing for retrial.
#
def emit_scrape_request parts
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

