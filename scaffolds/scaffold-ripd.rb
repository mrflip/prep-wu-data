#!/usr/bin/env ruby
require 'rubygems'
require 'erubis'
require 'fileutils'; include FileUtils::Verbose

input = File.read 'template.icss.yaml.erb'
eruby = Erubis::Eruby.new(input)

Dir['/data/ripd/*'].find_all{|d| File.directory? d}.each do |d|
  d = File.basename d
  icss_file = "ripd-scaffold/#{d}/#{d}.icss.yaml"
  mkdir_p File.dirname(icss_file)
  File.open(icss_file, 'w') do |f|
    f << eruby.result(:url => d)
  end
end

