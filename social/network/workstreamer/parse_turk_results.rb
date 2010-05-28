#!/usr/bin/env ruby
$: << "/Users/doncarlo/ics/gems/"
require 'rubygems'
require 'fastercsv'

# WORK_DIR = File.dirname(__FILE__).to_s + "/"
WORK_DIR = "/Users/doncarlo/Downloads/test2/results/"
TODAY = Time.now.strftime("%Y%m%d")
NETWORKS = ["linkedin","twitter","wikipedia","youtube"]

index = 3

results = FasterCSV.open(WORK_DIR + NETWORKS[index] + "-" + TODAY + ".results", options={:headers => true, :return_headers => true, :col_sep => "\t"})

accepted = File.open(WORK_DIR + NETWORKS[index] + "-" + TODAY + ".accepted","w")
accepted << ["hitid","hittypeid","assignmentid","workerid","Answer.Q1Url"].join("\t") + "\n"

approveids = File.open(WORK_DIR + NETWORKS[index] + "-" + TODAY + "-approve_ids.txt","w")
approveids << ["assignmentIdToApprove","assignmentIdToApproveComment"].join("\t") + "\n"

reviewhits = File.open(WORK_DIR + NETWORKS[index] + "-" + TODAY + "-further_review.results","w")
reviewhits << ["hitid","hittypeid","assignmentid","workerid","Answer.Q1Url","reject"].join("\t") + "\n"

hitids = Hash.new

results.each do |row|
  if row["hitstatus"] == "Reviewable"
    row["Answer.Q1Url"].strip!
    row["Answer.Q1Url"].gsub!(/http:\/\//,"")
    unless hitids.key?(row["hitid"])
      hitids[row["hitid"]] = row
      next
    end
    if hitids[row["hitid"]]["Answer.Q1Url"] == row["Answer.Q1Url"]
      accepted << [hitids[row["hitid"]]["hitid"],hitids[row["hitid"]]["hittypeid"],hitids[row["hitid"]]["assignmentid"],hitids[row["hitid"]]["workerid"],
        hitids[row["hitid"]]["Answer.Q1Url"]].join("\t") + "\n"
      approveids << [hitids[row["hitid"]]["assignmentid"],"Thanks!"].join("\t") + "\n"
      accepted << [row["hitid"],row["hittypeid"],row["assignmentid"],row["workerid"],row["Answer.Q1Url"]].join("\t") + "\n"
      approveids << [row["assignmentid"],"Thanks!"].join("\t") + "\n"
    end
    if hitids[row["hitid"]]["Answer.Q1Url"] != row["Answer.Q1Url"]
      reviewhits << [hitids[row["hitid"]]["hitid"],hitids[row["hitid"]]["hittypeid"],hitids[row["hitid"]]["assignmentid"],hitids[row["hitid"]]["workerid"],
        hitids[row["hitid"]]["Answer.Q1Url"],hitids[row["hitid"]]["reject"]].join("\t") + "\n"
      reviewhits << [row["hitid"],row["hittypeid"],row["assignmentid"],row["workerid"],row["Answer.Q1Url"],row["reject"]].join("\t") + "\n"
    end
    # puts row["Answer.Q1Url"]
  end
end