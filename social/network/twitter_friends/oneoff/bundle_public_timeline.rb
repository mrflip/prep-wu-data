#!/usr/bin/env ruby
require 'fileutils'; include FileUtils

WORK_DIR='/tmp/ripd'

# arch/public_timeline/public_timeline-200811.tar.bz2
# => public_timeline/200811/29/04/public_timeline-20081129-045042.json

TAR_RE = %r{(public_timeline)-(\d+)\.tar\.bz2}
def tar_contents_dir tar_filename
  m = TAR_RE.match(tar_filename) or raise "Don't grok archive filename '#{tar_filename}'"
  resource, scrape_session = m.captures
  resource.gsub!(/\-/, '/')
  "#{resource}/#{scrape_session}"
end

# --preserve-order
#               list of names to extract is sorted to match archive


mkdir_p WORK_DIR

cd WORK_DIR do
  $stdin.each do |tar_filename|
    tar_filename.chomp!
    dir = tar_contents_dir(tar_filename)
    puts dir
    if !File.exists?(dir)
      `hdp-cat #{tar_filename} | tar xjfk - --mode 644`
    end
    puts `ls`
    Dir[dir+'/**/*.json'].each do |scraped_filename|
      contents = File.open(scraped_filename).read
      next unless contents && (! contents.empty?)
      contents = contents.gsub(/\s+\z/, '').gsub(/[\t\r\n]+/, ' ')
      resource_key = scraped_filename.gsub(%r{^(public_timeline/\d+/\d+/\d+).*$}, '\1')
      puts [resource_key, scraped_filename, contents].join("\t")
    end
  end
end

