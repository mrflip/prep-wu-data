#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'yaml'
#require 'geonames'
#require 'xmlsimple'
require 'json'
require 'open-uri'
require 'cgi'
# require 'imw/utils/extensions/core'
# require 'active_support'
# require 'action_view/helpers/number_helper'; include ActionView::Helpers::NumberHelper
#
require 'lib/cities_mapping'

# q = Geonames::ToponymSearchCriteria.new
# { :q => 'fargo, ND', :max_rows => '5', :feature_codes => ['PPL'], :country_code => 'US'
# }.each{|attr, val| q.send("#{attr}=", val)}
# r = Geonames::WebService.search q
#
# puts r.to_yaml
#
# [:alternate_names, :country_code, :country_name, :distance, :elevation,
#   :feature_class, :feature_class_name, :feature_code, :feature_code_name,
#   :geoname_id, :latitude, :longitude, :name, :population, ]

puts '[ '
CITIES_MAPPING.each do |city, st, airport, cm_ll, cm_lng|
  url = "http://ws.geonames.org/search?maxRows=10&featureClass=P&continentCode=NA&type=json&q="
  query_city = CGI::escape("#{city}, #{st}")
  query = url + query_city
  result = open(query).read.chomp
  city_st_str = "[%-21s\"%s\"]:" % ["\"#{city}\",", st ]
  puts "  %-30s%s," % [city_st_str, result]
end
puts ']'

