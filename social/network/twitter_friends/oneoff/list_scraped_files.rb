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
  def process tar_filename, ls_line
    scraped_file = ScrapedFile.new_from_ls_line(ls_line)
    scraped_file.scrape_store = tar_filename; scraped_file.moreinfo = ''
    puts [scraped_file.keyspace_spread_resource_name, scraped_file.to_a].flatten.join("\t")
  end
end

class TarFileListingScript < Hadoop::Script
  def reduce_command
    '/bin/cat'
  end
end

TarFileListingScript.new(RenameMapper, nil).run
