#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'faster_csv'
require 'imw' ; include IMW
require 'hadoop_utils'; include HadoopUtils
# as_dset __FILE__

def load_line line
  line.parse_tsv
end

# ===========================================================================
#
# parse each line in STDIN
#
info_user_id, info_user_name = '', ''
last_line = ''
$stdin.each do |line|
  line.chomp! ; next if line.blank?
  # Take earliest unique line
  this_line = line.gsub(/\t\d{14}$/,'')
  if this_line == last_line then next; else last_line = this_line end
  # extract fields
  line_user_name, resource, *rest = load_line(line); next if rest.blank?
  # strip the sorting index
  resource = resource.gsub(/^\d\d_/, '').to_sym
  # capture user info when we see it.
  if (resource == :user) || (resource == :user_partial)
    info_user_name = line_user_name; info_user_id = rest[0]
  elsif line_user_name != info_user_name
    # ... and we should see a user or user_partial first
    puts [:scrape_user_info, line_user_name].flatten.to_tsv
    info_user_name = ''; info_user_id = 0
  end
  # Repair fields that have no #id field
  case resource
  when :a_follows_b, :b_follows_a
    if resource == :afollowsb
      follower_id, follower, friend, timestamp = rest
      friend_id   = info_user_id
    else # resource == :bfollowsa
      friend_id, friend, follower, timestamp = rest
      follower_id = info_user_id
    end
    # we need to preserve the username dump in case our eager join fails
    puts [:a_follows_b, follower_id, friend_id,   follower, friend,    timestamp].flatten.to_tsv
    puts [:b_follows_a, friend_id,   follower_id, friend,   follower,  timestamp].flatten.to_tsv
  when :a_atsigns_b
    user_a_id, user_a, user_b, status_id, timestamp = rest
    # we need to preserve the username dump in case our eager join fails
    puts [:a_atsigns_b, user_a_id,   info_user_id, user_a, user_b,  timestamp].flatten.to_tsv
  else
    puts [resource, rest].flatten.to_tsv
  end
end
