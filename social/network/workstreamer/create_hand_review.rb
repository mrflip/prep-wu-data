#!/usr/bin/env ruby
$: << "/Users/doncarlo/ics/gems/"
require 'rubygems'
require 'fastercsv'
require 'addressable/uri'

# WORK_DIR = File.dirname(__FILE__).to_s + "/"
WORK_DIR = "/Users/doncarlo/data/workstreamer/results/"
HIT_DIR = "/Users/doncarlo/data/workstreamer/"
TODAY = Time.now.strftime("%Y%m%d")
NETWORKS = ["facebook","linkedin","twitter","wikipedia","youtube"]

if NETWORKS.include?(ARGV[0])
  index = NETWORKS.index(ARGV[0])
else
  index = ARGV[0].to_i
end
puts "Getting results from #{NETWORKS[index]}."

needed = FasterCSV.open(HIT_DIR + NETWORKS[index] + '-needed-20100608.tsv', options={:headers => true, :col_sep => "\t"})
results = FasterCSV.open(WORK_DIR + NETWORKS[index] + '-20100608-further_review.results', options={:headers => true, :col_sep => "\t"})
review = File.open(WORK_DIR + NETWORKS[index] + '-' + TODAY + '-hand-review.tsv','w')
review << ["hitid","hittypeid","assignmentid","workerid","object_id","website","Answer.Q1Url"].join("\t") + "\n"

needed_ids = []

needed.each do |row|
  needed_ids += [row["object_id"]]
end

results.each do |row|
  if needed_ids.include?(row["object_id"])
    review << [row["hitid"],row["hittypeid"],row["assignmentid"],row["workerid"],row["object_id"],row["website"],row["Answer.Q1Url"]].join("\t") + "\n"    
    puts row
  end  
end
