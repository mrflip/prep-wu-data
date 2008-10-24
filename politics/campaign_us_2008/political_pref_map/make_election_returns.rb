#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'yaml'; require 'json'; require 'fastercsv'
require 'imw'; include IMW;
require 'imw/extract/html_parser'
require 'dm-core'
$: << File.dirname(__FILE__)+'/..'
as_dset __FILE__
require 'election_return'
#

#
# Extract County-By-County returns from the The USA Today, today.
#
#

# Year 2004:
#   http://www.usatoday.com/news/politicselections/vote2004/PresidentialByCounty.aspx?oi=P&rti=G&sp=AK&tf=l
# Year 2000:
#   http://www.usatoday.com/news/vote2000/cbc/map.htm

#
# State Files
#
STATES = %w[ak al ar az ca co ct dc de fl ga hi ia id il in ks ky la ma md me mi mn mo ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va vt wa wi wv wy]
def presidential_by_county_filename(st)
  path_to(:ripd, "www.usatoday.com/news/politicselections/vote2004/PresidentialByCounty.aspx?oi=P&rti=G&sp=#{st}&tf=l")
end
#
# State File Structure
#
raw_parser = HTMLParser.new({
    '//form/table//tr/td/table//tr' => {
      'td:first/b'                => :county,                   
      'td:eq(1)'                  => :total_precincts,
      'td:eq(2)'                  => :precincts_reporting,
      'td:eq(3)'                  => :bush,
      'td:eq(4)'                  => :kerry,
      'td:eq(5)'                  => :nader,
    }})

#
# Raw Election Returns
#

counties = []
STATES.each do |st|
  raw_rows = raw_parser.parse_file(presidential_by_county_filename(st))['//form/table//tr/td/table//tr']
  raw_rows.reject!{|row| row.values.length != 6 }
  raise "Have cruft before or after header row" unless raw_rows.shift[:precincts_reporting] =~ /Precincts Reporting/
  counties += raw_rows.map{|row| ElectionReturn.from_hash(row.merge({:st => st })) }
end


#
# Dump 
#
# as TSV
tsv_out_filename = 'election_returns_2004.tsv'
puts "Writing to intermediate file #{tsv_out_filename}"
FasterCSV.open(path_to(:fixd, tsv_out_filename), 'w', :col_sep => "\t") do |tsv_file|
  tsv_file << ElectionReturn.members
  counties.each do |county|
    tsv_file << county.to_a
  end
end
