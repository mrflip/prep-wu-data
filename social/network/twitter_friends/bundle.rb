#!/usr/bin/env ruby
require 'fileutils'; include FileUtils
$: << File.dirname(__FILE__)+'/lib'
require 'twitter_friends/scraped_file'
require 'hadoop/utils'

#
# Landing spot
#
WORK_DIR='/tmp/ripd'

# arch/public_timeline/public_timeline-200811.tar.bz2
# => public_timeline/200811/29/04/public_timeline-20081129-045042.json

TAR_RE = %r{(public_timeline)-([\d-]+)\.tar\.bz2}
def tar_contents_dir tar_filename
  m = TAR_RE.match(tar_filename) or raise "Can't grok archive filename '#{tar_filename}'"
  resource, scrape_session = m.captures
  resource.gsub!(/\-/, '/') ; scrape_session.gsub!(/\-/, '/')
  "#{resource}/#{scrape_session}"
end


def extract_tar_archive tar_filename, dir
  if !File.exists?(dir)
    `cat #{tar_filename} | tar xjfk - --mode 644`
  end
end

#
# !!! NOTE !!!
#
# A bundled file is NOT a conventional tar-separated file: consider the last
# field (containing the raw JSON) to be arbitrary text.
#
mkdir_p WORK_DIR
cd WORK_DIR do
  $stdin.each do |tar_filename|
    #
    # extract the archive
    #
    tar_filename.chomp!
    dir = tar_contents_dir(tar_filename)
    extract_tar_archive tar_filename, dir
    #
    # walk the directory tree
    #
    Dir[dir+'/**/*.json'].each do |scraped_filename|
      #
      # Grok filename
      #
      scraped_file = ScrapedFile.new_from_filename scraped_filename, nil
      #
      # extract file's contents
      #
      contents = File.open(scraped_filename).read
      next if (! contents) || contents.empty?
      contents = contents.gsub(/\s+\z/, '').gsub(/[\t\r\n]+/, ' ')
      #
      # emit context, scraped_at, identifier, filename, json_str
      #
      puts [scraped_file.values_of(:context, :scraped_at, :identifier, :filename), contents].flatten.join("\t")
    end
  end
end



#
# A useful tar arg:
#
# --preserve-order
#               list of names to extract is sorted to match archive

