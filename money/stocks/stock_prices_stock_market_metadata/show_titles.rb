#!/usr/bin/env ruby

$: << ENV['HOME']+'/ics/wukong/lib'
require "rubygems"
require "faster_csv"
require "yaml"
require "wukong"
require "wukong/encoding"

STOPWORDS_RE = %r{\b(?:
  and|of|the|
  co|corp|corporation|incorporated|inc|company|
  plc|lp|ltd|limited|llc|
  sa|de|cv|nv|ii|ag|tr|ctf|tbk
)\b}sx
# allowing   alliance|trust|group|fund|holdings|partners|

def scrub_title title
  title.
    downcase.
    gsub(/[\'\.\/]+/,"").      # O'Reilly, Frank's, etc.
    gsub(/[^a-zA-Z0-9\s]+/, " ").
    gsub(STOPWORDS_RE, "").
    strip.
    gsub(/\s+/s, "_")
end



# Dir["fixd/Symbol-Name-*.csv"].each do |fn|
#   FasterCSV.open(fn) do |f|
#     f.shift ; f.shift # nuke 2 header rows
#     f.each do |row|
#       title = row[0]
#       # puts "%-79s\t%s" % [scrub_title(title), title]
#       puts scrub_title(title)
#     end
#   end
# end


#  ./show_titles.rb | ~/ics/wukong/examples/word_count.rb --map | sort | ~/ics/wukong/examples/word_count.rb --reduce | sort -nk2 | tail -n 200


#
# DBPedia: "Company" infobox
#

companies_hsh = YAML.load(File.open("/data/fixd/huge/wikipedia/dbpedia/infobox_infobox_company-yaml/infobox_infobox_company.yaml"))

companies_hsh.map do |company, info|
  puts scrub_title(company)
end

# | sort > ~-/fixd/titles_from_infobox_company.tsv

#
# Index pages from wikipedia
#

# wget -O- 'http://en.wikipedia.org/w/api.php?action=query&titles=Companies_listed_on_the_New_York_Stock_Exchange_(0-9)&format=yaml&redirect&export'

