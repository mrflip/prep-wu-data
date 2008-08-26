#!/usr/bin/env ruby
require 'rubygems'
require 'dm-core'
require 'fileutils'; include FileUtils
require 'imw/utils'; include IMW; IMW.verbose = true
require 'json'
require 'yaml'
require 'digest/md5'
# require  File.dirname(__FILE__)+'/delicious_link_models.rb'
as_dset __FILE__

#
#  Usage
#   ./delicious_scrape_json_stupidly.rb >> ./log/delicious-json-scrape-`datename`.log 2>&1 &
#   tail -f ./log/delicious-json-scrape-`datename`.log &
#

require 'delicious_scrape_html_ugly'
DEL_BASE_URL = "feeds.delicious.com/v2/json"
HASHER = Digest::MD5.new

KEYSMAP = {
  # 'dt'       =>   :date,
  # 'd'        =>   :desc,
  # 'id'       =>   :id,
  # 'n'        =>   :name,
    't'        =>   :tag,
  # 'u''       =>   :url,
    :urlhash   =>   :urlhash,
    'user'     =>   :user,
}

def count_vals_stupidly()
  flattened = {
    # :date      =>   {},
    # :desc      =>   {},
    # :id        =>   {},
    # :name      =>   {},
    :tag       =>   {},
    # :url       =>   {},
    :urlhash   =>   {},
    :user      =>   {},
  }

  [nil, :networkfans, "*"].each do |feed|
    Dir[path_to([:ripd_root, DEL_BASE_URL, feed, "*"])].each do |f|
      next if (File.directory? f) || (File.size(f) < 1)
      # puts f
      infos = JSON.load File.open(f)
      infos.each do |info|
        info[:urlhash] = HASHER.hexdigest(info['u']) unless info['u'].blank?
        info.slice(*KEYSMAP.keys).each do |del_attr, val|
          attr = KEYSMAP[del_attr]
          case val
          when Array then
            val.each do |v|
              flattened[attr][v] ||= 0
              flattened[attr][v] += 1
            end
          else
            flattened[attr][val] ||= 0
            flattened[attr][val] += 1
          end
        end
      end
    end
  end
  flattened
end

def scrape_json_stupidly flattened, num_to_get=1000
  announce "Sorted Scraping #{num_to_get} popular links"
  flattened.slice(:tag, :urlhash).to_a.reverse.each do |attr, counts|
    successful = 0
    counts.sort_by(&:last).reverse.each do |val, count|
      puts "%5d current links: %-80s" % [count, val]
      get_delicious_json(attr, val) and (successful += 1)
      break if successful > num_to_get
    end
  end
end

cd path_to(:ripd_root) do
  (1..1000).to_a.each do |i|
    scrape_json_stupidly count_vals_stupidly, 50
  end
end
