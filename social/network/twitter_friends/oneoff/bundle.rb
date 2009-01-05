#!/usr/bin/env ruby
require 'fileutils'; include FileUtils
# [ screen_name, twitter_id, context, scrape_file.page, scraped_at, contents ].join("\t")+"\n"

RIPD_DIR = '/workspace/flip/data/ripd/_com/_tw/com.twitter/'
DATE_DIR = ARGV.first or raise "Need a directory"

cd(RIPD_DIR) do
  Dir[DATE_DIR+'/users/show'].each do |dir|
    Dir[dir+'/*'].each do |filename|
      contents = File.open(filename).read
      puts "%s\t%s\n" % [filename, contents]
    end
  end
end


