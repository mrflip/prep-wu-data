#!/usr/bin/env ruby
require 'imw/utils'
require 'imw/dataset'
include IMW; IMW.verbose = true
as_dset __FILE__

TWITTER_NAMES_FILE = [:fixd, 'stats/twitter_names.yaml']
TWITTER_404S_FILE  = [:fixd, 'stats/twitter_404s.yaml']
WGET_CMD     = "wget -x -nc -np -nv"
SLEEP_TIME_BETWEEN_REQS = 1

def load_404s
  if File.exist?(path_to(TWITTER_404S_FILE))
    DataSet.load(path_to(TWITTER_404S_FILE))
  else
    DataSet.new []
  end
end

# Scrape down to followed level *threshold*
def scrape_pass(threshold, twitter_404s)
  twitter_names    = DataSet.load(TWITTER_NAMES_FILE){ |data| data[:names] }
  banner "Starting a new scrape: threshold #{threshold} - #{twitter_names.length} names"
  FileUtils.cd path_to(:ripd) do
    twitter_names.each do |twitter_name, twitter_followedbys|
      twitter_name.chomp!
      break if twitter_followedbys < threshold
      next if twitter_404s.include? twitter_name
      next if File.exist?("twitter.com/#{twitter_name}")
      wget_output = `#{WGET_CMD} http://twitter.com/#{twitter_name} 2>&1`.chomp
      if wget_output =~ /ERROR 404/ then twitter_404s << twitter_name end
      puts "%7d\t%-25s\t%s " % [twitter_followedbys, twitter_name, wget_output] ; $stdout.flush
      sleep SLEEP_TIME_BETWEEN_REQS
    end
  end
end

def relist_names
  announce "Relisting names"
  announce `#{path_to(:me, "twitter_names_list.rb")}`.chomp
  announce "...done relisting"
end

twitter_404s = load_404s
([10, 6, 3, 6, 3, 10, 4, 2 ]*3 + [1]).flatten.each do |threshold|
  scrape_pass threshold, twitter_404s
  twitter_404s.dump TWITTER_404S_FILE
  relist_names
end
