#!/usr/bin/env ruby
$: << "/Users/doncarlo/ics/gems/"
require 'rubygems'
require 'fastercsv'

# WORK_DIR = File.dirname(__FILE__).to_s + "/"
WORK_DIR = "/Users/doncarlo/data/workstreamer/results/"
TODAY = Time.now.strftime("%Y%m%d")
NETWORKS = ["facebook","linkedin","twitter","wikipedia","youtube"]

if NETWORKS.include?(ARGV[0])
  index = NETWORKS.index(ARGV[0])
else
  index = ARGV[0].to_i
end
puts "Getting results from #{NETWORKS[index]}."

results = FasterCSV.open(WORK_DIR + NETWORKS[index] + "-" + TODAY + ".results", options={:headers => true, :return_headers => true, :col_sep => "\t"})

accepted = File.open(WORK_DIR + NETWORKS[index] + "-" + TODAY + ".accepted","w")
accepted << ["hitid","hittypeid","assignmentid","workerid","annotation","Answer.Q1Url"].join("\t") + "\n"

approveids = File.open(WORK_DIR + NETWORKS[index] + "-" + TODAY + "-approve_ids.txt","w")
approveids << ["assignmentIdToApprove","assignmentIdToApproveComment"].join("\t") + "\n"

reviewhits = File.open(WORK_DIR + NETWORKS[index] + "-" + TODAY + "-further_review.results","w")
reviewhits << ["hitid","hittypeid","assignmentid","workerid","annotation","Answer.Q1Url","reject"].join("\t") + "\n"

hitids = Hash.new

results.each do |row|
  if ((row["hitstatus"] == "Reviewable") && (row["assignmentstatus"] != "Approved"))
    row["Answer.Q1Url"].strip!
    row["Answer.Q1Url"].delete!('"')
    row["Answer.Q1Url"].gsub!(/https?:\/\//,"")
    unless hitids.key?(row["hitid"])
      hitids[row["hitid"]] = row
      next
    end
    if NETWORKS[index] == "facebook"
      row["Answer.Q1Url"].gsub!(/facebook.com\/[^#]*\#\!/,"facebook.com")
      row["Answer.Q1Url"].gsub!(/\?ref\=.+/,"")
      row["Answer.Q1Url"].gsub!(/\&ref\=.+/,"")
      row["Answer.Q1Url"].gsub!(/\?v\=.+/,"")
    end
    if NETWORKS[index] == "twitter"
      intersection = hitids[row["hitid"]]["Answer.Q1Url"].delete(" ").downcase.split(",") & row["Answer.Q1Url"].delete(" ").downcase.split(",")
      unless intersection.empty?
        puts intersection.join(",")
        accepted << [hitids[row["hitid"]]["hitid"],hitids[row["hitid"]]["hittypeid"],hitids[row["hitid"]]["assignmentid"],hitids[row["hitid"]]["workerid"],
          intersection.join(",")].join("\t") + "\n"
        approveids << [hitids[row["hitid"]]["assignmentid"],"Thanks!"].join("\t") + "\n"
        accepted << [row["hitid"],row["hittypeid"],row["assignmentid"],row["workerid"],intersection.join(",")].join("\t") + "\n"
        approveids << [row["assignmentid"],"Thanks!"].join("\t") + "\n"
        next
      end
      reviewhits << [hitids[row["hitid"]]["hitid"],hitids[row["hitid"]]["hittypeid"],hitids[row["hitid"]]["assignmentid"],hitids[row["hitid"]]["workerid"],
        hitids[row["hitid"]]["Answer.Q1Url"].downcase,hitids[row["hitid"]]["reject"]].join("\t") + "\n"
      reviewhits << [row["hitid"],row["hittypeid"],row["assignmentid"],row["workerid"],row["Answer.Q1Url"].downcase,row["reject"]].join("\t") + "\n"
    else
      if hitids[row["hitid"]]["Answer.Q1Url"].downcase == row["Answer.Q1Url"].downcase
        accepted << [hitids[row["hitid"]]["hitid"],hitids[row["hitid"]]["hittypeid"],hitids[row["hitid"]]["assignmentid"],hitids[row["hitid"]]["workerid"],
          hitids[row["hitid"]]["annotation"],hitids[row["hitid"]]["Answer.Q1Url"].downcase].join("\t") + "\n"
        approveids << [hitids[row["hitid"]]["assignmentid"],"Thanks!"].join("\t") + "\n"
        accepted << [row["hitid"],row["hittypeid"],row["assignmentid"],row["workerid"],row["annotation"],row["Answer.Q1Url"].downcase].join("\t") + "\n"
        approveids << [row["assignmentid"],"Thanks!"].join("\t") + "\n"
      end
      if hitids[row["hitid"]]["Answer.Q1Url"].downcase != row["Answer.Q1Url"].downcase
        reviewhits << [hitids[row["hitid"]]["hitid"],hitids[row["hitid"]]["hittypeid"],hitids[row["hitid"]]["assignmentid"],hitids[row["hitid"]]["workerid"],
          hitids[row["hitid"]]["annotation"],hitids[row["hitid"]]["Answer.Q1Url"].downcase,hitids[row["hitid"]]["reject"]].join("\t") + "\n"
        reviewhits << [row["hitid"],row["hittypeid"],row["assignmentid"],row["workerid"],row["annotation"],row["Answer.Q1Url"].downcase,row["reject"]].join("\t") + "\n"
      end
    end
    # puts row["Answer.Q1Url"]
  end
end
