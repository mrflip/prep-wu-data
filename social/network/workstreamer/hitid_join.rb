#!/usr/bin/env ruby
$: << "/Users/doncarlo/ics/gems/"
require 'rubygems'
require 'fastercsv'

# WORK_DIR = File.dirname(__FILE__).to_s + "/"
WORK_DIR = "/Users/doncarlo/Downloads/test2/results/"
HIT_DIR = "/Users/doncarlo/Downloads/test2/"
TODAY = Time.now.strftime("%Y%m%d")
NETWORKS = ["facebook","linkedin","twitter","wikipedia","youtube"]

index = 4

results = FasterCSV.open(WORK_DIR + NETWORKS[index] + "-" + TODAY + "-further_review.results", options={:headers => true, :col_sep => "\t"})

websites = FasterCSV.open(HIT_DIR + NETWORKS[index] + "_hitid_website.tsv", options={:headers => true, :col_sep => "\t"})

review = File.open(WORK_DIR + NETWORKS[index] + "-" + TODAY + "-further_review_website.results","w")
review << ["hitid","hittypeid","assignmentid","workerid","object_id","display_name","website","Answer.Q1Url","reject"].join("\t") + "\n"

hitids = Hash.new

websites.each do |row|
  hitids[row["hitid"]] = {:object_id => row["object_id"],:display_name => row["display_name"],:website => row["website"]}
end

results.each do |row|
  unless hitids.key?(row["hitid"])
    puts "Missing hitid:#{row["hitid"]}\tWebsite:#{row["Answer.Q1Url"]}"
    next
  end
  review << [row["hitid"],row["hittypeid"],row["assignmentid"],row["workerid"],
    hitids[row["hitid"]][:object_id],hitids[row["hitid"]][:display_name],hitids[row["hitid"]][:website],
    row["Answer.Q1Url"],row["reject"]].join("\t") + "\n"
end