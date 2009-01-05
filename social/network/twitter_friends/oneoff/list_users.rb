#!/usr/bin/env ruby
require 'fileutils'; include FileUtils

WORK_DIR='/tmp/ripd'

# ripd-20081203-users-show.tar.bz2 => _com/_tw/com.twitter/_20081203/users/show/

TAR_RE = %r{ripd-(\w+)-([\w\-]+)\.tar\.bz2}
def tar_contents_dir tar_filename
  m = TAR_RE.match(tar_filename) or raise "Don't grok archive filename '#{tar_filename}'"
  scrape_session, resource = m.captures
  resource.gsub!(/\-/, '/')
  "_com/_tw/com.twitter/_#{scrape_session}/#{resource}"
end

# --preserve-order
#               list of names to extract is sorted to match archive


mkdir_p WORK_DIR

cd WORK_DIR do
  $stdin.each do |tar_filename|
    tar_filename.chomp!
    `hdp-cat arch/ripd/#{tar_filename} | tar xjfk - --mode 644`
    dir = tar_contents_dir(tar_filename)
    Dir[dir+'/*'].each do |scraped_filename|
      contents = File.open(scraped_filename).read
      puts [tar_filename, contents].join("\t")
    end
  end
end

