#!/usr/bin/env ruby
$: << "/Users/doncarlo/ics/gems/"
require 'rubygems'
require 'fastercsv'

# WORK_DIR = File.dirname(__FILE__).to_s + "/"
WORK_DIR = "/Users/doncarlo/data/workstreamer/results/"
HIT_DIR = "/Users/doncarlo/data/workstreamer/"
TODAY = Time.now.strftime("%Y%m%d")
NETWORKS = ["facebook","linkedin","twitter","wikipedia","youtube"]

index = 0

# results = FasterCSV.open(WORK_DIR + NETWORKS[index] + "-" + TODAY + "-further_review.results", options={:headers => true, :col_sep => "\t"})
results = FasterCSV.open(WORK_DIR + NETWORKS[index] + "-" + TODAY + ".confirm", options={:headers => true, :col_sep => "\t"})

websites = FasterCSV.open(HIT_DIR + "20100528-" + NETWORKS[index] + "-single_hitid_website.tsv", options={:headers => true, :col_sep => "\t"})

singlehit = File.open(HIT_DIR + NETWORKS[index] + "-" + TODAY + "_new_single_HIT.tsv","w")
singlehit << ["object_id","display_name","website"].join("\t") + "\n"

doublehit = File.open(HIT_DIR + NETWORKS[index] + "-" + TODAY + "_new_double_HIT.tsv","w")
doublehit << ["object_id","display_name","website"].join("\t") + "\n"

oldhits = File.open(HIT_DIR + NETWORKS[index] + "-" + TODAY + "_old_HIT.tsv","w") 
oldhits << ["hitid","hittypeid","object_id","display_name","website"].join("\t") + "\n"

deletehits = File.open(HIT_DIR + NETWORKS[index] + "-" + TODAY + "_delete_HIT.tsv","w")
deletehits << ["hitid","hittypeid"].join("\t") + "\n"

# review = File.open(WORK_DIR + NETWORKS[index] + "-" + TODAY + "-further_review_website.results","w")
# review << ["hitid","hittypeid","assignmentid","workerid","object_id","display_name","website","Answer.Q1Url","reject"].join("\t") + "\n"

# hitids = Hash.new
#
# websites.each do |row|
#   hitids[row["hitid"]] = {:object_id => row["object_id"],:display_name => row["display_name"],:website => row["website"]}
# end

approved = []
openhits = Hash.new

results.each do |row|
  approved += [row["hitid"]] if ((row["assignmentstatus"] == "Approved") && !(approved.include?(row["hitid"])))
  openhits[row["hitid"]] = row if row["assignmentstatus"] == "Submitted"
  # unless hitids.key?(row["hitid"])
  #   puts "Missing hitid:#{row["hitid"]}\tWebsite:#{row["Answer.Q1Url"]}"
  #   next
  # end
  # review << [row["hitid"],row["hittypeid"],row["assignmentid"],row["workerid"],
  #   hitids[row["hitid"]][:object_id],hitids[row["hitid"]][:display_name],hitids[row["hitid"]][:website],
  #   row["Answer.Q1Url"],row["reject"]].join("\t") + "\n"
end

puts "Approved HITids: #{approved.uniq.length}"

websites.each do |row|
  next if approved.include?(row["hitid"])
  unless openhits.key?(row["hitid"])
    deletehits << [row["hitid"],row["hittypeid"]].join("\t") + "\n"
    doublehit << [row["object_id"],row["display_name"],row["website"]].join("\t") + "\n"
    next
  end
  if openhits[row["hitid"]]["hitstatus"] == "Reviewable"
    singlehit << [row["object_id"],row["display_name"],row["website"]].join("\t") + "\n"
    oldhits << [row["hitid"],row["hittypeid"],row["object_id"],row["display_name"],row["website"]].join("\t") + "\n"
    next
  end
  if openhits[row["hitid"]]["hitstatus"] == "Assignable"
    doublehit << [row["object_id"],row["display_name"],row["website"]].join("\t") + "\n"
    oldhits << [row["hitid"],row["hittypeid"],row["object_id"],row["display_name"],row["website"]].join("\t") + "\n"
    next
  end
end
