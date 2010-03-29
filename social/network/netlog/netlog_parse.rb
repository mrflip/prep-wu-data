#!/usr/bin/env ruby
require 'rubygems'
require 'imw'

test_page = 'http://en.netlog.com/go/explore/music/artistID=71&view=fans&page=1' #Linkin Park fans page on Netlog

fan_page_data = IMW.open(test_page)
fans = fan_page_data.parse ["div.avatar", {:listing => ["span.vcard", {
  :url => "span.url", 
  :full_name => "span.fn", 
  :first_name => "span.given-name", 
  :last_name => "span.family-name",
  :nickname => "span.nickname",
  :photo_link => "span.photo",
  :country => "span.adr/span.country-name",
  :region => "span.adr/span.adr"}]}]
fans = fans.map{ |fan| fan = [fan[:listing][0][:nickname], fan[:listing][0][:url], fan[:listing][0][:first_name], fan[:listing][0][:last_name], 
  fan[:listing][0][:full_name], fan[:listing][0][:region], fan[:listing][0][:country], fan[:listing][0][:photo_link]] }
fans.each{ |fan| puts fan.join("\t")}