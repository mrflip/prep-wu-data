#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require './ukdata_dm'

WORK_DIR = "/data/work/data.gov.uk/dump/"
data_json_flat_file = WORK_DIR + "data.gov.uk-flat.json"

data_uk = JSON.load(IO.read(data_json_flat_file).gsub(/\n/,""))

data_uk.each do |dataset|
  id, title, url, author, a_email, maintainer, m_email, license, license_id, tags, rev_id = dataset.values_at("id","title","download_url","author","author_email","maintainer","maintainter_email","license","license_id","tags","revision_id")
  description = dataset["notes"]
  if dataset["resources"].size > 1
    dataset["resources"].each do |resource|
      name = resource["description"].gsub(/\s\|\shttp\:\/\/.+/,"")
      link = resource["url"]
      if name == ""
        description += "\n\n# [\"#{link}\":#{link}]"
      else
        description += "\n\n# [\"#{name}\":#{link}]"
      end
      next unless resource['format'] != ""
      format = resource["format"]
      description += "\n** Format: #{format}"
    end
  end
  extras = ""
  dataset["extras"].each do |key, value|
    next unless value != ""
    extras += "#{key.gsub(/\_/," ").capitalize}: #{value}\n"
  end
  ukdd = UkDataset.create(
    :id => id, :title => title, :url => url.gsub(/\!/,"%21").gsub(/\"\"/,"").gsub(/[\[\]]/,"").gsub(/83\.244\.183\.180/,"83-244-183-180.cust-83.exponential-e.net"), 
    :author => author, :author_email => a_email, :maintainer => maintainer, :maintainer_email => m_email, :license => license, :license_id => license_id,
    :tags => tags.join(","), :revision_id => rev_id, :description => description, :extras => extras)
  ukdd.save
end