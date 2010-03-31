#!/usr/bin/env ruby
$: << '../../infochimps-data/scaffolds/importYAML/'
require 'rubygems'
require 'importyaml'
require 'ukdata_dm'

YAML_DIR = '/Users/doncarlo/ics/yaml_files/data.gov.uk/'

# Make a new collection called Data.gov.uk

collection = [{'collection'=>{'title'=>'Data.gov.uk','description'=>'Data.gov.uk seeks to give a way into the wealth of government data. As highlighted by the Power of Information Taskforce, this means it needs to be:

* easy to find;
* easy to license; and
* easy to re-use.

They are drawing on the expertise and wisdom of Sir Tim Berners-Lee and Professor Nigel Shadbolt to publish government data as RDF - enabling data to be linked together.'}}]

# Make a new source of Data.gov.uk

datagovuk_source = [{'source'=>{'title'=>'Data.gov.uk','description'=>'Data.gov.uk seeks to give a way into the wealth of government data. As highlighted by the Power of Information Taskforce, this means it needs to be:

* easy to find;
* easy to license; and
* easy to re-use.

They are drawing on the expertise and wisdom of Sir Tim Berners-Lee and Professor Nigel Shadbolt to publish government data as RDF - enabling data to be linked together.','main_link'=>'http://data.gov.uk/'}}]

all_datasets = []
# sources = []
long_title = 0
no_url = 0
long_url = 0
no_tags = 0
long_tags = 0
uploaded = 0

fix_listings = File.open("uk_datasets_to_fixup.tsv","w")

UkDataset.all.each do |dataset|
  taglengthflag = false
  if dataset.url == ""
    no_url += 1
    fix_listings << [dataset.id, "Reason: No URL"].join("\t") + "\n"
    next
  end
  if dataset.url.length > 255
    long_url += 1
    fix_listings << [dataset.id, "Reason: Long URL"].join("\t") + "\n"
    next
  end
  if dataset.tags == ""
    no_tags += 1
    fix_listings << [dataset.id, "Reason: No tags"].join("\t") + "\n"
    next
  end
  tag_arry = dataset.tags.gsub(/\,\s/,",").gsub(/\s/,"-").split(",")
  tag_arry.each do |tag|
    if tag.length > 25
      long_tags += 1
      taglengthflag = true
      fix_listings << [dataset.id, "Tag too long: #{tag}"].join("\t") + "\n"
    end
  end
  if taglengthflag
    tag_arry.delete_if{ |tag| tag.length > 25 }
  end
  if dataset.title.length > 100
    long_title += 1
    fix_listings << [dataset.id, "Title too long: #{dataset.title}"].join("\t") + "\n"
    next
  end
  data_yaml = DatasetYAML.new(:title => dataset.title, :subtitle => "from Data.gov.uk", :main_link => dataset.url, :description => dataset.description, :tags => tag_arry,
    :owner => "Infochimps", :protected => "true", :collection => "Data.gov.uk")
  data_yaml.sources = ["Data.gov.uk"]
#  sources += [dataset.author] if !(sources.include?(dataset.author))
  data_yaml.description += "\n\n" + dataset.extras if dataset.extras != ""
  data_yaml.description += "\n\nTags:" + dataset.tags if taglengthflag
  all_datasets += data_yaml.to_a
  dataset.uploaded = Time.now.utc
  dataset.save
  uploaded += 1
end

fix_listings << "Long title count: #{long_title}\nNo url count: #{no_url}\nNo tags count: #{no_tags}\nTotal to fix: #{long_title + no_url + no_tags}\nTotal uploaded: #{uploaded}\n"

#source_yaml = File.open("data.gov.uk_source.yaml","w")
#source_yaml << datagovuk_source.to_yaml

#collection_yaml = File.open("data.gov.uk_collection.yaml","w")
#collection_yaml << collection.to_yaml

data_yaml = File.open(YAML_DIR + "data.gov.uk_datasets.yaml","w")
data_yaml << all_datasets.to_yaml