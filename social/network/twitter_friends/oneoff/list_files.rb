#!/usr/bin/env ruby
require 'fileutils'; include FileUtils
require 'imw/utils/uri'

WORK_DIR='/tmp/ripd'
mkdir_p WORK_DIR

class ScrapedFile < Struct.new(
    :screen_name, :user_id, :resource, :page,
    :scrape_session,
    :scraped_at, :size,
    :filename
    )



  FILENAME_RE = %r{com.twitter/_(\d+)/([\w/]+)/(.+)\.json%3Fpage%3D(\d+)\+(\d+)-(\d+)\.json}
  def self.new_from_ls size, filename
    m = FILENAME_RE.match(filename)
    if (!m) then
      warn "Can't grok #{filename}"
      return self.new('!!BOGUS!!',nil,nil,nil,nil,nil,size, filename)
    end
    user_id = ''
    scrape_session, resource, screen_name, page, dt, tm = m.captures
    scraped_at = dt + tm
    screen_name = Addressable::URI.unencode_segment(screen_name)
    self.new(screen_name, user_id, resource, page, scrape_session, scraped_at, size, filename)
  end

  def emit
    puts self.to_a.join("\t")
  end
end

cd WORK_DIR do
  $stdin.each do |tar_filename|
    tar_filename.chomp!
    `hdp-cat arch/ripd/#{tar_filename} | tar tjvf - | egrep '\.json$'`.split("\n").each do |line|
      mode, ug, size, dt, tm, filename = line.chomp.split(/\s+/)
      scraped_file = ScrapedFile.new_from_ls(size, filename)
      scraped_file.emit if scraped_file
    end
  end
end

