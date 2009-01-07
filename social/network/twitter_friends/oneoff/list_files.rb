#!/usr/bin/env ruby
require 'fileutils'; include FileUtils
$: << File.dirname(__FILE__)+'/../lib'
require 'hadoop/tsv'
require 'hadoop/utils'
require 'hadoop/script'
require 'hadoop/streamer'
require 'twitter_friends/scraped_file'
require 'twitter_friends/scrape_store'
# require 'twitter_friends/json_model'

#
# Input:
#
#  hdp-ls arch/ripd | grep 'bz2' | hdp-put - rawd/scraped_files/scrape_stores.txt
#

#
# Flat listing of each scrape store
#
class RenameMapper < Hadoop::Streamer
  def process *filelisting
    tar_filename = filelisting.last.split(/\s+/).last # handle an ls listing or flat list.
    scrape_store = TarScrapeStore.new(tar_filename)
    scrape_store.listing.each do |line|
      puts tar_filename + "\t" + line
    end
  end
end

class TarFileListingScript < Hadoop::Script
  def reduce_command
    '/bin/cat'
  end
end

TarFileListingScript.new(RenameMapper, nil).run
