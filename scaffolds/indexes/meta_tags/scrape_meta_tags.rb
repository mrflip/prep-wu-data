#!/usr/bin/env ruby
require 'rubygems'
require 'dm-core'
require 'fileutils'; include FileUtils
require 'imw'; include IMW
require 'imw/dataset'
require 'imw/dataset/asset'
require 'imw/extract/html_parser'
as_dset __FILE__

#
# Extract information from header and prominent page tags
#
GENERIC_PAGE_STRUCTURE = {
    '//head' => {
      'title'                                      => :page_title,
      { 'meta[@name="keywords"]'     => :content } => :keywords ,
      { 'meta[@name="description"]'  => :content } => :description,
      { 'link[@rel="Shortcut Icon"]' => :href    } => :favicon_url,
    },
    '//body//h1' => [:h1],
    '//body//h2' => [:h2],
    '//body//caption' => [:table_captions]
  }



class FilePoolProcessor
  include Asset::Processor
  attr_accessor :assets

  def assets_to_parse
    asset_query = { :handle.like => '%/url/%page=1' }
    LinkAsset.all(asset_query)
  end

  def parse
    delicious_parser = DeliciousAssetsHTMLParser.new(DELICIOUS_PAGE_STRUCTURE)
    self.assets = process(assets_to_parse, :delicious, delicious_parser)
  end

end
processor = FilePoolProcessor.new

Dataset.all.each do |dataset|
  # Cache a copy of each page
  linky = dataset.links.first
  linky.wget :root => [:rawd, 'scrapes'], :noisy => false
  # Parse, pivot
  parsed = els.parse_html_file('rawd/scrapes/'+linky.ripd_file)
  next unless parsed; if !parsed['//head'].blank? then parsed.merge!( parsed.delete('//head')[0]||{} ) end
  puts parsed.to_yaml

  # Stuff into dataset
  dataset.notes << dataset.notes.find_or_create({ :role => 'scraped_title'      }, :desc => parsed[:page_title]  ) if !parsed[:page_title].blank?
  dataset.notes << dataset.notes.find_or_create({ :role => 'scraped_description'}, :desc => parsed[:description] ) if !parsed[:description].blank?
  dataset.links << dataset.links.find_or_create({ :role => '_favicon_url'       }, :full_url => parsed[:favicon_url], :name => 'favicon' ) if !parsed[:favicon_url].blank?
  dataset.tag_with :scraped_meta_keywords, parsed[:keywords]
  page_headers = parsed.values_at(:h1, :h2, :table_captions).flatten.compact.join("\n")
  dataset.notes << dataset.notes.find_or_create({ :role => 'scraped_header_tags_from_page'}, :name => '<h1>, <h2> and <caption> tags', :desc => page_headers )
  dataset.credit(robo_contrib, :role => 'harvested', :desc => 'Some data harvested by our robochimp.')
  dataset.save
end
