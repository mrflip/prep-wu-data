#!/usr/bin/env ruby
require 'rubygems'
require 'json' ; require 'yaml'
$: << File.dirname(__FILE__)+'/../twitter_friends/lib'
require 'hadoop'
require 'panel_models'

include Hadoop::StructItemizer
File.open('fixd/panel_ideas_parsed.tsv').each do |line|
  next unless line =~ /^panel_idea/
  begin
    idea = Hadoop::StructItemizer.itemize(*line.chomp.split("\t")).first
  rescue; next ; end
  #
  name = idea.name.hadoop_decode
  name = name.downcase
  name = name.gsub(/\W+/, " ")
  #
  url  = idea.url
  url  = url.downcase
  url  = url.gsub(%r{http://},'').gsub(%r{^www\.}, '').gsub(%r{/.*}, '')
  #
  org  = idea.org.hadoop_decode
  org  = org.downcase
  org.gsub!(/\W+/, " ")
  org.gsub!(/\b(inc|com|net|org)\b/, ' ')
  org.gsub!(/\W+/, " ")
  puts [url, name, org].join("\t")
end
