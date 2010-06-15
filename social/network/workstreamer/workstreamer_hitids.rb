#!/usr/bin/env ruby
require 'rubygems'
require 'fastercsv'
require './standard_datamapper_setup'
DataMapper.setup_db_connection 'imw_workstreamer'
require './workstreamer_models'

HIT_DIR = "/Users/doncarlo/data/workstreamer/"
NETWORKS = [
  # "facebook",
  "linkedin","twitter","wikipedia","youtube"]

NETWORKS.each do |net|
  hitids = FasterCSV.open(HIT_DIR + "20100528-" + net + "_hitid_website.tsv", options={:headers => true, :col_sep => "\t"})
  hitids.each do |row|
    company = JuneCompanyListing.get(row["object_id"])
    warn "Record mismatch!" if company["website"] != row["website"]
    unless company[net].nil?
      warn "Record already exists for #{company["display_name"]}: #{company[net]}"
      next
    end
    # puts "DB company: #{company["display_name"]}"
    # puts "HIT list company: #{row["display_name"]}"
    company[net+"_hitid"] = row["hitid"]
    company.save
  end
end