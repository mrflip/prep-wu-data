#!/usr/bin/env ruby

require "rubygems"
# ' -x http://twitter.com/meangrape02

# WGET_EXCLUDE = "/*/*,/account,/favourites,/favorites,/help,/images,/*/statuses,/statuses,*/favourites,*/favorites"
# WGET_REC_ARGS = "--wait=2 --random-wait -X'#{WGET_EXCLUDE}'"
WGET_CMD     = "wget -x -nc -np -nv"

RAWD = "/data/new/twitter"
SLEEP_TIME_BETWEEN_REQS = 2

# Scrape down to followed level *threshold*
def scrape_pass(threshold)
  print "!"*75 + "\n#{Time.now} Starting a new scrape down to #{threshold} - "
  `./twitter_ids_make.sh`
  id_lines = File.open("#{RAWD}/twitter_ids.txt").readlines
  puts "#{id_lines.length} ids", "!"*75
  $stderr.puts "#{Time.now} #{threshold} - #{id_lines.length}"
  id_lines.each do |line|
    _, user_n, user_id = " #{line}".split(/\s+/)

    break if user_n.to_i < threshold
    next if File.exist?("twitter.com/#{user_id}")
    $stderr.print "%5d %-25s " % [user_n, user_id]
    `#{WGET_CMD} http://twitter.com/#{user_id}`
    sleep SLEEP_TIME_BETWEEN_REQS
  end
end


([10, 6, 4, 10, 6, 3, 10, 4, 2 ]*3 + [1]).flatten.each do |threshold|
  scrape_pass threshold
end

# histogram
#   cat ../twitter_ids.txt | ruby -ne 'puts $_.split(/\s+/)[1]' | uniq -c
#   36 24
#   47 23
#   67 22
#   49 21
#   68 20
#   83 19
#   94 18
#   89 17
#   88 16
#  102 15
#  120 14
#  136 13
#  154 12
#  199 11
#  255 10
#  260 9
#  352 8
#  468 7
#  612 6
#  800 5
# 1239 4
# 2049 3
# 4458 2
# 17979 1
