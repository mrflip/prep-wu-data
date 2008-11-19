#!/usr/bin/env ruby
require 'fileutils'

lines = `links -width 160 -dump 'http://www.editorandpublisher.com/eandp/news/article_display.jsp?vnu_content_id=1003875230'`
# lines = File.open('/tmp/foo').read
lines = lines.gsub(/\A.*?(BARACK OBAMA.*?)WEEKLIES .*? COLLEGE.*?(CHOOSING.*?NO ENDORSEMENT.*?)--------------.*/m, '\1\2')

year = 2008
destdir                    = "versioned/endorsements_#{year}/"
endorsement_orig_filename  = destdir+"endorsements-raw-#{Time.now.strftime("%Y%m%d")}-orig.txt"
endorsement_raw_filename   = destdir+"endorsements-raw-#{Time.now.strftime("%Y%m%d")}.txt"
endorsement_patch_filename = "ripd/endorsements-raw-#{year}-patch.diff"
filedest                   = "ripd/endorsements-raw-#{year}-eandp.txt"
File.open(endorsement_orig_filename, 'w') do |f|
  f << lines
end
puts `patch -F4 #{endorsement_orig_filename} -o #{endorsement_raw_filename} < #{endorsement_patch_filename}`
FileUtils.cp(endorsement_raw_filename, filedest)

puts "Read #{lines.split(/\n/).length} lines into #{endorsement_raw_filename} (and #{filedest})"
