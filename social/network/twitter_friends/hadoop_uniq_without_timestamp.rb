#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'faster_csv'
require 'imw' ; include IMW
require 'hadoop_utils'; include HadoopUtils
# as_dset __FILE__

# ===========================================================================
#
# parse each line in STDIN
#
line_timestamp_uniqifier = LineTimestampUniqifier.new
$stdin.each do |line|
  line.chomp!
  next if line.blank? || line_timestamp_uniqifier.is_repeated?(line)
  puts line
end
