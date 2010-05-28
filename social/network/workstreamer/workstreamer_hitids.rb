#!/usr/bin/env ruby
require 'rubygems'
require 'fastercsv'
require './standard_datamapper_setup'
DataMapper.setup_db_connection 'imw_workstreamer'
require './workstreamer_models'

HIT_DIR = "/Users/doncarlo/Downloads/test2/"
NETWORKS = ["facebook","linkedin","twitter","wikipedia","youtube"]

NETWORKS.each do |net|
  hitids = FasterCSV.open(HIT_DIR + net + "_hitid_website.tsv", options={:headers => true, :col_sep => "\t"})
  hitids.each do |row|
    company = JuneCompanyListing.get(row["object_id"])
    warn "Record mismatch!" if company["website"] != row["website"]
    company[net+"_hitid"] = row["hitid"]
    company.save
  end
end