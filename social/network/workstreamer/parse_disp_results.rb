#!/usr/bin/env ruby
$: << "/Users/doncarlo/ics/gems/"
require 'rubygems'
require 'fastercsv'

# WORK_DIR = File.dirname(__FILE__).to_s + "/"
WORK_DIR = "/Users/doncarlo/data/workstreamer/results/"
HIT_DIR = "/Users/doncarlo/data/workstreamer/"
TODAY = Time.now.strftime("%Y%m%d")
NETWORKS = ["linkedin","twitter","wikipedia","youtube"]

if NETWORKS.include?(ARGV[0])
  index = NETWORKS.index(ARGV[0])
else
  index = ARGV[0].to_i
end
puts "Getting results from #{NETWORKS[index]}."

round1_hitid_websites = FasterCSV.open(HIT_DIR + NETWORKS[index] + '_hitid_website.tsv', options={:headers => true, :col_sep => "\t"})
round1_results = FasterCSV.open(WORK_DIR + NETWORKS[index] + '-20100528-further_review.results', options={:headers => true, :quote_char => "`", :col_sep => "\t"})
round2_hitid_double = FasterCSV.open(HIT_DIR + '20100528-' + NETWORKS[index] + '_hitid_website.tsv', options={:headers => true, :col_sep => "\t"})
round2_hitid_single = FasterCSV.open(HIT_DIR + '20100528-' + NETWORKS[index] + '-single_hitid_website.tsv', options={:headers => true, :col_sep => "\t"})
round2_double_results = FasterCSV.open(WORK_DIR + NETWORKS[index] + '-' + TODAY + '-further_review.results', options={:headers => true, :quote_char => "`", :col_sep => "\t"})
round2_single_results = FasterCSV.open(WORK_DIR + NETWORKS[index] + '-' + TODAY + '-single.results', options={:headers => true, :col_sep => "\t"})

website_ids = Hash.new

round1_hitid_websites.each do |row|
  warn "Duplicate HITid: #{row["hitid"]}" if website_ids.key?(row["hitid"])
  website_ids[row["hitid"]] = {"id" => row["object_id"], "website" => row["website"]}
end

round2_hitid_double.each do |row|
  warn "Duplicate HITid: #{row["hitid"]}" if website_ids.key?(row["hitid"])
  website_ids[row["hitid"]] = {"id" => row["object_id"], "website" => row["website"]}
end

round2_hitid_single.each do |row|
  warn "Duplicate HITid: #{row["hitid"]}" if website_ids.key?(row["hitid"])
  website_ids[row["hitid"]] = {"id" => row["object_id"], "website" => row["website"]}
end

p website_ids.first

all_results = Hash.new

round1_results.each do |row|
  warn "Missing HITid:#{row["hitid"]}" unless website_ids.key?(row["hitid"])
  object_id = website_ids[row["hitid"]]["id"]
  all_results[object_id] = {"match_found" => false, "results" => []} unless all_results.key?(object_id)
  all_results[object_id]["results"] += [{"hitid" => row["hitid"], "hittypeid" => row["hittypeid"], "assignmentid" => row["assignmentid"], "workerid" => row["workerid"],
    "Answer.Q1Url" => row["Answer.Q1Url"], "object_id" => object_id, "website" => website_ids[row["hitid"]]["website"], "approve" => false}
  ]
end

round2_double_results.each do |row|
  warn "Missing HITid:#{row["hitid"]}" unless website_ids.key?(row["hitid"])
  object_id = website_ids[row["hitid"]]["id"]
  all_results[object_id] = {"match_found" => false, "results" => []} unless all_results.key?(object_id)
  all_results[object_id]["results"] += [{"hitid" => row["hitid"], "hittypeid" => row["hittypeid"], "assignmentid" => row["assignmentid"], "workerid" => row["workerid"],
    "Answer.Q1Url" => row["Answer.Q1Url"], "object_id" => object_id, "website" => website_ids[row["hitid"]]["website"], "approve" => false}
  ]
end

round2_single_results.each do |row|
  if ((row["hitstatus"] == "Reviewable") && (row["assignmentstatus"] != "Approved"))
    row["Answer.Q1Url"].strip!
    row["Answer.Q1Url"].gsub!(/http:\/\//,"")
    warn "Missing HITid:#{row["hitid"]}" unless website_ids.key?(row["hitid"])
    object_id = website_ids[row["hitid"]]["id"]
    all_results[object_id] = {"match_found" => false, "results" => []} unless all_results.key?(object_id)
    all_results[object_id]["results"] += [{"hitid" => row["hitid"], "hittypeid" => row["hittypeid"], "assignmentid" => row["assignmentid"], "workerid" => row["workerid"],
      "Answer.Q1Url" => row["Answer.Q1Url"], "object_id" => object_id, "website" => website_ids[row["hitid"]]["website"], "approve" => false}
    ]
  end
end

p all_results.first 

all_results.each do |object_id,raw|
  (0..raw["results"].size-2).each do |index1|
    (index1+1..raw["results"].size-1).each do |index2|
      if raw["results"][index1]["Answer.Q1Url"] == raw["results"][index2]["Answer.Q1Url"]
        # puts "Found match for #{raw["results"][index1]["Answer.Q1Url"]} == #{raw["results"][index2]["Answer.Q1Url"]}"
        all_results[object_id]["match_found"] = true
        all_results[object_id]["results"][index1]["approve"] = true
        all_results[object_id]["results"][index2]["approve"] = true
      end
    end
  end
  # p all_results[object_id] if all_results[object_id]["match_found"] 
end

# Writing out to new files here

accepted = File.open(WORK_DIR + NETWORKS[index] + "-" + TODAY + "-obj_ids.accepted","w")
accepted << ["hitid","hittypeid","assignmentid","workerid","object_id","website","Answer.Q1Url"].join("\t") + "\n"
approve_ids = File.open(WORK_DIR + NETWORKS[index] + "-" + TODAY + "-approve_ids-other.txt","w")
approve_ids << ["assignmentIdToApprove","assignmentIdToApproveComment"].join("\t") + "\n"
reject_ids = File.open(WORK_DIR + NETWORKS[index] + "-" + TODAY + "-reject_ids-other.txt","w")
reject_ids << ["assignmentIdToReject","assignmentIdToRejectComment"].join("\t") + "\n"

all_results.each do |object_id,raw|
  if raw["match_found"]
    raw["results"].each do |result|
      if result["approve"]
        accepted << [result["hitid"],result["hittypeid"],result["assignmentid"],result["workerid"],result["object_id"],result["website"],result["Answer.Q1Url"]].join("\t") + "\n"
        approve_ids << [result["assignmentid"],"Thanks!"].join("\t") + "\n"
      else
        reject_ids << [result["assignmentid"],"Sorry, answer did not match."].join("\t") + "\n"
      end
    end
  end
end