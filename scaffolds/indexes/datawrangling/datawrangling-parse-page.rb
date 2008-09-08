#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'dm-core'
require 'fileutils'; include FileUtils
require 'imw/utils'; include IMW; IMW.verbose = true
require 'imw/extract/hpricot'
require 'imw/extract/html_parser'
require 'json'
require 'yaml'
require  File.dirname(__FILE__)+'/ics-models.rb'
as_dset __FILE__

dw_contrib = Contributor.create({
    :name => 'Pete Skomoroch',
    :url  => 'http://datawrangling.com',
    :desc => '(From http://datawrangling.com/about):

Director of Advanced Analytics at Juice and live in the Washington, DC area. I’m also a consultant for various machine learning, finance, and information retrieval related projects which come my way.

Before relocating to DC in 2006, I was a member of the Biodefense Systems group at MIT Lincoln Laboratory where my work spanned several areas including machine learning algorithms, monte carlo simulations, wireless sensor networks, and web based decision support systems. Prior to joining the lab, I worked for several years at a Cambridge startup called Profitlogic (acquired by Oracle), where I constructed predictive models and software for retail revenue optimization. I was also a database consultant at Fidelity Investments focusing on Oracle and Java. Graduated from Brandeis University with a double major in mathematics and physics, and have done some non-degree graduate coursework in machine learning and neural networks at MIT. I have research experience in physics, biology, and computer science.',
    :base_trustification => 20,
  })

els = HTMLParser.new({
      '//div.entrybody/ul/li' => {
        { 'a' => :href          } => :link_url ,
        { 'a' => :tags          } => :tags,
        'a'                       => :desc,
        { 'a' => :last_visit    } => :last_visit,
        { 'a' => :add_date      } => :add_date,
      }
    })

parsed = els.parse_html_file('rawd/scrapes/www.datawrangling.com/some-datasets-available-on-the-web')
parsed = parsed.to_a[0][1] #discard first level
# puts parsed.to_yaml

parsed.each do |linky|
  dataset = Dataset.find_or_create(:url        => linky[:link_url])
  dataset.description = linky[:desc]
  dataset.tag_with(:dw, linky[:tags])
  dataset.add_internal_note(:datawrangling_page, linky)
  dataset.register_info(:harvested, :datawrangling)
  dataset.credit(dw_contrib, :role => 'indexed', :desc => 'This link harvested from the index on Pete Skomoroch\'s blog, http://www.datawrangling.com/some-datasets-available-on-the-web')
  dataset.save
end
