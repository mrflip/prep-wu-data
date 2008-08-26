#!/usr/bin/env ruby
require 'rubygems'
require 'dm-core'
require 'fileutils'; include FileUtils
require 'imw/utils'; include IMW; IMW.verbose = true
require 'imw/extract/hpricot'
require 'json'
require 'yaml'
require  File.dirname(__FILE__)+'/delicious_link_models.rb'
require  File.dirname(__FILE__)+'/html_parser.rb'
# as_dset 'urls/bulk/delicious', :cut_dirs => 0

class DeliciousLinksParser < HTMLParser
  # pivot parse_links' intermediate structure into yaml records
  def transform_parsed_to_records records
    return if records.blank?
    tagged_date = ''
    records = records['//#bookmarklist/li']
    records.map do |rec_in|
      #puts rec_in.to_yaml
      rec_out = {}
      rec_out[:delicious_id]  = rec_in[:delicious_id][0].gsub(/^(?:[a-z]+-)?([0-9a-f]{32})(?:-.{0,2})/, '\1')
      rec_in  = rec_in['div.bookmark'][0]
      tagged_date = rec_in['.dateGroup/span'] ? rec_in['.dateGroup/span'][0][:date_tagged][0] : tagged_date
      rec_out[:date_tagged]  = tagged_date
      rec_out[:url]  = rec_in['.data/h4/a.taggedlink'].first[:url].first
      rec_out.merge! rec_in.slice(:savers_count, :tags, :description, :name)
      rec_out
    end
  end
end

OUT_DIR      = File.expand_path('~/ics/bulk/fixd/delicious.com')
OUT_ALL_FILE = File.expand_path('~/ics/bulk/fixd/delicious-all-links.yaml')
def output_del_file del_file
  del_file =~ %r{delicious.com/(.*)} or raise "don't know where to put #{del_file}"
  out_file = File.join(OUT_DIR, $1+'.yaml')
  mkdir_p File.dirname(out_file)
  out_file
end

delicious_files.each do |delicious_file|
  out_file = output_del_file(delicious_file)
  if File.exists?(out_file)
    announce("  #{delicious_file}: reading cached")
    data += YAML.load(File.open(out_file))
  else
    announce("  #{delicious_file}: parsing")
    newdata = uc.transform_links_structure(uc.parse(delicious_file, uc.links_structure))
    next if newdata.blank?
    announce("  #{delicious_file}: parsed")
    data += newdata
    YAML.dump(newdata, File.open(out_file, 'w'))
  end
end
YAML.dump(data, File.open(OUT_ALL_FILE, 'w'))
