#!/usr/bin/env ruby
require 'fileutils'; include FileUtils
$: << File.dirname(__FILE__)+'/../lib'
require 'hadoop/tsv'
require 'hadoop/utils'
require 'hadoop/script'
require 'hadoop/streamer'
require 'twitter_friends/scraped_file'
# require 'twitter_friends/json_model'

DATERANGE = [20081126..20081130, 20081201..20081231, 20090101..20090106, ].map(&:to_a).flatten
HOURRANGE = (0..23).map{|hr| "%02d"%hr }

BASE_PATH = 'new/_com/_tw/com.twitter'

cd ENV['HOME']+'/ics/data/ripd' do
  DATERANGE.each do |date|
    HOURRANGE.each do |hour|
      TwitterApi::RESOURCE_PATH_FROM_CONTEXT.each do |context, resource_path|
        mkdir_p "%s/_%s/_%s/%s" % [BASE_PATH, date, hour, resource_path]
      end
    end
  end
end
