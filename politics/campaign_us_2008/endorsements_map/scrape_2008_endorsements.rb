#!/usr/bin/env ruby
require 'fileutils'

lines = `links -dump 'http://www.editorandpublisher.com/eandp/news/article_display.jsp?vnu_content_id=1003875230'`
# lines = File.open('/tmp/foo').read
lines = lines.gsub(/\A.*?(BARACK OBAMA.*?)WEEKLIES . COLLEGE.*/m, '\1')

destdir                  = 'ripd/endorsements_2008/'
endorsement_raw_filename = "endorsements-raw-#{Time.now.strftime("%Y%m%d")}.txt"
linkdest                 = 'endorsements-raw.txt'
File.open(destdir+endorsement_raw_filename, 'w') do |f|
  f << lines
end
FileUtils.rm(destdir+linkdest) if File.exist? destdir+linkdest
FileUtils.ln_s(endorsement_raw_filename, destdir+linkdest)


puts "Read #{lines.split(/\n/).length} lines into #{endorsement_raw_filename}"
