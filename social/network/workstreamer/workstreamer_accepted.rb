#!/usr/bin/env ruby
require 'rubygems'
require 'fastercsv'
require './standard_datamapper_setup'
DataMapper.setup_db_connection 'imw_workstreamer'
require './workstreamer_models'

Configliere.use :define, :commandline
Settings.define :accpeted_turks, :description => "A file with accepted Mechanical Turk results."
Settings.resolve!

p Settings

# HIT_DIR = "/Users/doncarlo/Downloads/test2/"
NETWORKS = ["facebook","linkedin","twitter","wikipedia","youtube"]

# net = Settings[:accepted_turks].scan(/(\w+)\-\d{8}\.accepted$/).to_s
net = $1 if Settings[:accepted_turks] =~ /(facebook|linkedin|twitter|wikipedia|youtube)/
warn "Invalid network name: #{net}" unless NETWORKS.include?(net)

results = FasterCSV.open(Settings[:accepted_turks], options={:headers => true, :col_sep => "\t"})

results.each do |row|
  if Settings[:accepted_turks] =~ /obj_ids/
    company = JuneCompanyListing.first("object_id" => row["object_id"])
  else
    company = JuneCompanyListing.first((net + "_hitid").to_s => row["hitid"])
  end
  if company.nil?
    warn "No company match: #{row["hitid"]}"
    next
  end
  unless company[net].nil?
    warn "#{net} URL for #{company["display_name"]} already exists."
    next
  end
  # puts "Putting #{row["Answer.Q1Url"]} in for #{row["website"]}."
  if net == "twitter"
    # need to put in something here to extract only the screen names
    twitter_accts = "None"
    twitter_accts = row["Answer.Q1Url"].split(",").map{|sn| sn = sn.strip.scan(/twitter.com\/(.+)$/)}.flatten.join(",") unless row["Answer.Q1Url"].strip.downcase == "none"
    company[net] = twitter_accts
    company.save
  else
    company_link = "None"
    company_link = "http://" + row["Answer.Q1Url"].strip unless row["Answer.Q1Url"].strip.downcase == "none"
    company[net] = company_link
    company.save
  end
end
