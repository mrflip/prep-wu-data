#!/usr/bin/env ruby
require 'rubygems'
require 'imw'

data_page = 'http://www.datasf.org/?page=1'
raw = IMW.open(data_page)
datasets = raw.parse [ "div.stories" , {:title => "div.title/h2/a", :description => "span.news-body-text/span", :url => "span.news-body-text/span/a"} ]

datasets = datasets.map{ |dataset| dataset = [dataset[:title], dataset[:description], dataset[:url]]}

#datasets.each{|dataset| puts dataset.join("\t")}

datasets.each{|dataset| puts dataset[2]}