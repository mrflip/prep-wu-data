#!/usr/bin/env ruby
require 'rubygems'
require 'configliere'
require 'fastercsv'
require 'logger'

Configliere.use :commandline, :define
Settings.define :turkfile, :description => "Resulting Mechanical Turk file to join."
Settings.define :companyfile, :description => "Original list of companies."
Settings.define :outfile, :description => "File to output joined list."
Settings.define :network, :description => "Type of network for the given turk file. (Twitter, Wikipedia, LinkedIn, etc.)"
Settings.define :compurlcol, :description => "Column number in the original company file with the company URL."
Settings.resolve!

Log = Logger.new($stderr) unless defined?(Log)

WORK_DIR = File.dirname(__FILE__).to_s + "/"

NETWORKS = {'twitter' => "Twitter Profiles (comma-delimited and verified)",
            'linkedin' => "Linkedin",
            'wikipedia' => "Wikipedia",
            'yahoo' => "Yahoo/Google Finance",
            'google' => "Yahoo/Google Finance",
            'manta' => "Manta",
            'zoominfo' => "Zoominfo",
            'blog' => "Corporate Blog",
            'facebook' => "Facebook",
            'flickr' => "Flickr",
            'youtube' => "YouTube",
            'scribd' => "Scribd",
            'delicious' => "Del.icio.us"}

p Settings.turkfile

turk = FasterCSV.open(WORK_DIR + Settings.turkfile, options={:headers => true}) unless Settings.turkfile.nil?
p turk
company = FasterCSV.open(WORK_DIR + Settings.companyfile, options={:headers => true, :return_headers => true}) unless Settings.companyfile.nil?
p company
output = FasterCSV.open(WORK_DIR + Settings.outfile, "w") unless Settings.outfile.nil?
p output

# 
# Create a hash of the results from Mechanical Turk.
# 
turk_result_hash = Hash.new
turk.each do |row|
  turk_result_hash[row['Input.website']] = row['Answer.Q1Url']
end

# 
# Write the headers to the output file to keep the headers the same.
# 
output << company.readline if company.header_row?

# 
# Match the results from Mechanical Turk with the correct column in the company file.
#   
company.each do |row|
  if Settings.network.downcase == 'twitter'
    twitter_accounts = turk_result_hash[row['website']].split(",").map{|url| url.lstrip.gsub(/https?\:\/\/w?w?w?\.?twitter.com\/([^\/]+).*/,'\1')}.join(",")
    row[NETWORKS[Settings.network.downcase]] = twitter_accounts
  else
    network_url = turk_result_hash[row['website']] 
    if !(network_url =~ /^https?\:\/\//) && network_url.to_s.downcase != 'none' && !(network_url.nil?)
      network_url = "http://" + network_url
    end
    row[NETWORKS[Settings.network.downcase]] = network_url
    Log.info "Setting #{row['display_name']}'s #{Settings.network} website to #{network_url}."
  end
  # p row
  output << row
end