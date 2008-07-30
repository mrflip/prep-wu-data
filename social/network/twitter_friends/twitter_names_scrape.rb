#!/usr/bin/env ruby
require "rubygems"
require "YAML"
require 'fileutils'

POOL=File.dirname(__FILE__)
FIXD=POOL+'/fixd'
RIPD=POOL+'/ripd'

# WGET_EXCLUDE = "/*/*,/account,/favourites,/favorites,/help,/images,/*/statuses,/statuses,*/favourites,*/favorites"
# WGET_REC_ARGS = "--wait=2 --random-wait -X'#{WGET_EXCLUDE}'"
WGET_CMD     = "wget -x -nc -np -nv"
SLEEP_TIME_BETWEEN_REQS = 1

# Scrape down to followed level *threshold*
def scrape_pass(threshold)
  puts "!"*75
  puts "#{Time.now}\tStarting a new scrape"
  twitter_names = YAML.load(File.open("#{FIXD}/stats/twitter_names.yaml"))[:names]
  puts "#{Time.now}\tthreshold #{threshold} - #{twitter_names.length} names", "!"*75
  FileUtils.cd RIPD do
    twitter_names.each do |twitter_name, twitter_followedbys|
      twitter_name.chomp!
      break if twitter_followedbys < threshold
      next if File.exist?("twitter.com/#{twitter_name}")
      wget_output = `#{WGET_CMD} http://twitter.com/#{twitter_name} 2>&1`.chomp
      puts "%7d\t%-25s\t%s " % [twitter_followedbys, twitter_name, wget_output] ; $stdout.flush
      sleep SLEEP_TIME_BETWEEN_REQS
    end
  end
  puts "#{Time.now}\tRelisting names"
  puts Time.now.to_s + "\t" + `#{POOL}/twitter_names_list.rb`.chomp
end


([10, 6, 4, 10, 6, 3, 10, 4, 2 ]*3 + [1]).flatten.each do |threshold|
  scrape_pass threshold
end
