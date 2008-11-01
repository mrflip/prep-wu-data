#!/usr/bin/env ruby
require 'fileutils'

lines = `links -width 160 -dump 'http://www.editorandpublisher.com/eandp/news/article_display.jsp?vnu_content_id=1003875230'`
# lines = File.open('/tmp/foo').read
lines = lines.gsub(/\A.*?(BARACK OBAMA.*?)WEEKLIES .*? COLLEGE.*?(CHOOSING.*?NO ENDORSEMENT.*?)--------------.*/m, '\1\2')

year = 2008
destdir                    = "ripd/endorsements_#{year}/"
endorsement_orig_filename  = "endorsements-raw-#{Time.now.strftime("%Y%m%d")}-orig.txt"
endorsement_raw_filename   = "endorsements-raw-#{Time.now.strftime("%Y%m%d")}.txt"
endorsement_patch_filename = "endorsements-raw-#{year}-patch.diff"
linkdest                   = "endorsements-raw-#{year}.txt"
File.open(destdir+endorsement_orig_filename, 'w') do |f|
  f << lines
end
puts `patch -F4 #{destdir+endorsement_orig_filename} -o #{destdir+endorsement_raw_filename} < #{destdir+endorsement_patch_filename}`
FileUtils.rm(destdir+linkdest) if File.exist? destdir+linkdest
FileUtils.ln_s(endorsement_raw_filename, destdir+linkdest)


puts "Read #{lines.split(/\n/).length} lines into #{endorsement_raw_filename}"
