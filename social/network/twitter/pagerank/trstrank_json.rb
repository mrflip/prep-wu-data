#!/usr/bin/env ruby
require 'rubygems'
require 'tsv_to_json'
include TSVtoJSON

Settings.use :commandline, :define
Settings.define :source, :description => "The source file to convert to JSON."
Settings.define :dest, :description => "Where to write the resulting JSON data."
Settings.resolve!

Settings.json_keys = ["screen_name","id","trstrank_raw","trstrank","followers_count","friends_count","statuses_count","created_at"].join(",")
exclude = ["trstrank_raw"]

trst = File.open(Settings.source)
dest = File.open(Settings.dest, "w")

trst.each do |line|
  row = line.chomp.split("\t")
  screen_name, id = row[0..1]
  # puts [screen_name, id, TSVtoJSON::into_json(row,exclude)].join("\t")
  dest << [screen_name, id, TSVtoJSON::into_json(row,exclude)].join("\t") + "\n"
end