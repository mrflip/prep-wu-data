#!/usr/bin/env ruby

#
# Reads in dates from specified path and uses it to run
# the twitter parser
#

#
# parse_type is {api|stream|search}
# datesfile is assumed to be a flat list of dates
#
parse_type = ARGV[0]
datesfile  = ARGV[1]

File.readlines(datesfile).each do |parsedate|
  system %Q{ echo ./parse_twitter #{parse_type} #{parsedate} }
end
