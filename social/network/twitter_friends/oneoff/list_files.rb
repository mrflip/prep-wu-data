#!/usr/bin/env ruby
require 'fileutils'; include FileUtils
$: << File.dirname(__FILE__)+'/../lib'
require 'hadoop/tsv'
require 'hadoop/utils'
require 'hadoop/script'
require 'hadoop/streamer'
require 'twitter_friends/scraped_file'
require 'twitter_friends/json_model'
include Hadoop

WORK_DIR='/tmp/ripd'
mkdir_p WORK_DIR

cd WORK_DIR do
  $stdin.each do |tar_filename|
    tar_filename.chomp!
    `hdp-cat arch/ripd/#{tar_filename} | tar tjvf - | egrep '\.json$'`.split("\n").each do |line|
      scraped_file = ScrapedFile.new_from_ls_line(line)
      puts scraped_file.output_form
    end
  end
end
