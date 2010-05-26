#!/usr/bin/env ruby
require 'rubygems'
require './standard_datamapper_setup'
DataMapper.setup_db_connection 'imw_workstreamer'
WORK_DIR = File.dirname(__FILE__)+'/work'
require './workstreamer_models'

FinalCompanyListing.auto_migrate!

PartialCompanyListing.all.each do |company|
  finished = FinalCompanyListing.new(company.attributes)
  TurkResult.all(:display_name => company.display_name).each do |result|
    case result.in_network
    when "Twitter"
      twitter = result.a_url.split(",").map{|url| url.lstrip.gsub(/h?t?t?p?s?\:?\/?\/?w?w?w?\.?twitter.com\/([^\/]+).*/,'\1')}.join(",")
      # puts "Twitter result: #{twitter}"
      finished.twitter_all = twitter
    when "YouTube"
      youtube = result.a_url
      # puts "YouTube result: #{youtube}"
      finished.youtube = youtube
    when "Facebook" then 
      facebook = result.a_url
      # puts "Facebook result: #{facebook}"
      finished.facebook = facebook
    end
  end
  finished.save
end


# :in_website => company.website