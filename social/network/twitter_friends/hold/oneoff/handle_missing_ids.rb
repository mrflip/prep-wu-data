#!/usr/bin/env ruby
require 'set'
require 'fileutils' ; include FileUtils
# $stderr.puts "#{Time.now} loading since-found screen names..."
# require 'have_screen_names'
# $stderr.puts "#{Time.now} ...done: #{HAVE_SCREEN_NAMES.length} ids"

$stderr.puts "#{Time.now} loading ids..."
require 'user_names_and_ids'
$stderr.puts "#{Time.now} ...done: #{ID_LIST.length} ids"

FIXD_PATH='/home/flip/ics/pool/social/network/twitter_friends/fixd'


# cd '/workspace/flip/data/ripd' do
#   Dir[FIXD_PATH+'/dump/missing_ids_20*'].each do |filename|
#     File.open(filename).each do |line|
#       screen_name, *vals = line.chomp.split "\t"
#       scraped_filename = vals.last
#       context = %r{statuses/(\w+)/}.match(scraped_filename).captures.first
#       have_user_file = HAVE_SCREEN_NAMES.include?(screen_name)
#       puts [ context, ID_LIST[screen_name], have_user_file, screen_name, scraped_filename ].join("\t")
#
#       # if (! have_user_file ) && (! ID_LIST[screen_name])
#       #   mkdir_p 'bogus/'+File.dirname(scraped_filename)
#       #   mv filename, 'bogus/'+scraped_filename
#       #   sleep 1
#       # end
#     end
#   end
# end

$stderr.each do |line|
  key, item_key, scraped_at, screen_name, context, page, size, scrape_session,*_ = line.split("\t") ; next unless scrape_session
  next if context == 'user'
  puts screen_name unless ID_LIST[screen_name]
end
