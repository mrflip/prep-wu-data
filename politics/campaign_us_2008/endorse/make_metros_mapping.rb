#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'iconv'; $KCODE = 'u'
require 'rubygems'
require 'yaml'; require 'json'
require 'fastercsv'
require 'imw'; include IMW
require 'imw/utils/extensions/core'
require 'imw/extract/flat_file_parser'
load '../endorse/state_abbreviations.rb'
$: << File.dirname(__FILE__)+'/..'
as_dset __FILE__
#
require 'newspaper_mapping'
require 'metropolitan_areas'

#
# Filenames
#
CITIES_TO_METROS_CENSUS_FILENAME = path_to(:ripd, 'www.census.gov/population/www/metroareas/lists/2007/List2.txt')

#
# Use census files to map cities to their metros
#
# File format:
# http://www.census.gov/population/www/metroareas/lists/2007/List1.txt
# i5   .3 .3 s67
# i5   ...s70                                                                   ...i2...i5
# CBSA                                                                           FIPS    FIPS
# Code    CBSA Titles and Principal Cities                                      State   Place
# 49780   Zanesville, OH Micropolitan Statistical Area
# 49780      Zanesville, OH                                                        39   88084
#
# http://www.census.gov/population/www/metroareas/lists/2007/List1.txt
# i5   ..i5   ....i5   .3 s
# i5   ..i5   ....i5   .3 .6    s
#                 FIPS
# CBSA   Div      State/
# Code   Code     County  CBSA and Division Titles and Components
# 49780                   Zanesville, OH Micropolitan Statistical Area
# 49780           39119         Muskingum County, OH
#

CityMetro.class_eval do
  cattr_accessor :all_metros
  self.all_metros = { }
  # Look up metros by CBSA code
  def self.load_flat_census_file(keep_lines, city_re, msa_re, census_filename)
    to_metros = { }
    lines = File.open(census_filename).readlines[keep_lines]
    cbsa_code, metro_name, metro_city, metro_st, metro_stature = ['', '', '', '']
    lines.each do |line|
      line.chomp!
      case
      when (line =~ /^\s*$/) then metro = ''; next
      when (m = city_re.match(line))
        cbsa_code, city_st, fips_state, fips_place = m.captures
        st, city = fix_city(city_st)
        to_metros[ [st, city] ] = CityMetro.new(st, city, fips_state, fips_place, cbsa_code, metro_name, metro_stature )
      when (m = msa_re.match(line)) # ((?:\w\w-)*(?:\w\w))
        cbsa_code, metro_name = m.captures; cbsa_code = cbsa_code.to_i
        metro_name = metro_name.gsub(/Metropolitan Statistical Area/, 'MSA').gsub(/Micropolitan Statistical Area/, 'uSA')
        metro_name.gsub!(/--/, '-')
        metro_city, metro_st, metro_stature = /([^,]+), (\S+) ([Mu]SA)/.match(metro_name).captures
        self.all_metros[cbsa_code] = [cbsa_code, metro_name, metro_city, metro_st, metro_stature]
      else
        warn "Bad line #{line}"
      end
    end
    to_metros
  end
  def self.load_cities_to_metros(census_filename)
    puts "Loading cities_to_metros from raw file..."
    keep_lines = 10..-1 # 11..-8
    city_re    = /^(\d{5})      (.{67})   (\d{2})   (\d{5})/
    msa_re     = /^(\d{5})   (.+)/
    @cities_to_metros = load_flat_census_file(keep_lines, city_re, msa_re, census_filename)
    MISSING_FROM_METROS.each do |st_city, cbsa_code|
      st, city = st_city
      _, metro_name, metro_city, metro_st, metro_stature = self.all_metros[cbsa_code] || NECTAS[cbsa_code]
      @cities_to_metros[st_city] = CityMetro.new(st, city, nil, nil, cbsa_code, metro_name, metro_stature)
    end
    NOT_METROS.each do |st_city|
      @cities_to_metros[st_city] = nil
    end
    @cities_to_metros
  end
  def self.load_counties_to_metros(census_filename)
  end

  #
  # Extract city and state from 'city, st';
  # handle special cases.
  #
  CITY_FIXER = {
    ['ID', 'Boise City'                  ] => 'Boise',
    ['IN', 'Indianapolis city'           ] => 'Indianapolis',
    ['KY', 'Louisville/Jefferson County' ] => 'Louisville',
    ['GA', 'Athens-Clarke County'        ] => 'Athens',
    ['GA', 'Augusta-Richmond County'     ] => 'Augusta',
    ['MT', 'Butte-Silver Bow'            ] => 'Butte',
    ['AR', 'Helena-West Helena'          ] => 'Helena',
    ['KY', 'Lexington-Fayette'           ] => 'Lexington',
    ['TN', 'Nashville-Davidson'          ] => 'Nashville',
    ['CA', 'Phoenix Lake-Cedar Ridge'    ] => 'Phoenix Lake',
  }
  NECTAS = {
    77350 => [77350, 'Rochester-Dover, NH-ME Metropolitan NECTA',         'Rochester-Dover',             'NH-ME', 'MNECTA'],
    76150 => [76150, 'North Adams, MA-VT Micropolitan NECTA',             'North Adams',                 'MA-VT', 'uNECTA'],
    71650 => [71650, 'Lowell-Billerica-Chelmsford, MA-NH NECTA Division', 'Lowell-Billerica-Chelmsford', 'MA-NH', 'NECTA Division'],
    72250 => [72250, 'Brunswick, ME Micropolitan NECTA',                  'Brunswick',                   'ME',    'uNECTA'],
  }
  MISSING_FROM_METROS = {
    # These are in NECTAs
    ['NH', 'Dover'              ]  => 77350,            # 77350           3301718820         Dover city, NH             Rochester-Dover, NH-ME Metropolitan NECTA
    ['MA', 'North Adams'        ]  => 76150,            # 76150           2500346225         North Adams city, MA       North Adams, MA-VT Micropolitan NECTA
    ['MA', 'Lowell'             ]  => 71650,            # 71650   74804   2501737000         Lowell city, MA            Lowell-Billerica-Chelmsford, MA-NH NECTA Division
    ['ME', 'Brunswick'          ]  => 72250,            # 72250           2300508430         Brunswick town, ME         Brunswick, ME Micropolitan NECTA
    # Not explicitly listed -- looked up by county.
    ['NJ', 'Hackensack'         ]  => 35620,
    ['NJ', 'Asbury Park'        ]  => 35620,
    ['NY', 'West Nyack'         ]  => 35620,
    ['NY', 'Melville'           ]  => 35620,
    ['CA', 'San Gabriel'        ]  => 31100,
    ['CA', 'Marin County'       ]  => 41860,
    ['CA', 'Monterey'           ]  => 41500,
    ['OH', 'Hamilton'           ]  => 17140,
    ['PA', 'Easton'             ]  => 10900,
    ['VA', 'Falls Church'       ]  => 47900,
    ['DE', 'New Castle'         ]  => 37980,
    ['PA', 'Greensburg'         ]  => 38300,
    ['CO', 'Longmont'           ]  => 14500,
    ['CO', 'Vail'               ]  => 20780,
    ['IL', 'Waukegan'           ]  => 16980,
  }
  NOT_METROS = Set.new([
    # http://en.wikipedia.org/wiki/Colorado_census_statistical_areas
    ['CO', 'Aspen'              ],       # no - Pitkin County
    ['CO', 'Cedaredge'          ],       # no - Delta County
    ['CO', 'Cortez'             ],       # no - Montezuma County
    ['CO', 'Gunnison'           ],       # no - Gunnison
    ['CO', 'Ouray County'       ],       # no - Ouray County
    # http://en.wikipedia.org/wiki/Nebraska_census_statistical_areas
    ['NE', 'McCook'             ],       # no - Red Willow County
    ['',   '']
  ])
  def self.fix_city(city_st)
    city_st.gsub!(/ \((?:part|balance)\)\s*/i,'')
    if m = /^([^,]+), (\w\w)\s*$/.match(city_st) then
      city, st = m.captures
    else
      city = city_st; st = ''; warn "Bad City: #{city_st}"
    end
    city = CITY_FIXER[[st, city]] || city
    [st, city]
  end
end

MetropolitanArea.class_eval do
  #
  # Load it from the excel-generated TSV file
  #
  def self.load_tsv()
    puts "Loading all_metros from raw file..."
    lines = File.open('metropolitan_areas.tsv').readlines
    line = lines.shift until line =~ /^\d+\t/; lines.unshift line
    @all_metros = []
    lines.each do |line|
      line.chomp!
      metro = self.new( *line.split(/\t/) )
      [:pop_2007, :pop_2000, :pop_rank, :pop_at_or_above].each do |attr|
        metro[attr] = metro[attr].to_i
      end
      [:pop_chg_pct_00_07, :pop_chg_pct_avg, :pop_aoa_pct,].each do |attr|
        metro[attr] = metro[attr].gsub(/%$/, '').to_f
      end
      [:metro_st, :metro_name, :metro_nickname, :csa_name].each do |attr|
        metro[attr] = metro[attr].gsub(/^"(.*)"$/, '\1') if metro[attr]
      end
      fix_msa_names = {
        'Charleston-North Charleston, SC MSA'            => 'Charleston-North Charleston-Summerville, SC MSA',
        'Myrtle Beach-Conway-North Myrtle Beach, SC MSA' => 'Myrtle Beach-North Myrtle Beach-Conway, SC MSA',
        'Kennewick-Richland-Pasco, WA MSA'               => 'Kennewick-Pasco-Richland, WA MSA',
        'Atlantic City, NJ MSA'                          => 'Atlantic City-Hammonton, NJ MSA',
        'Sarasota-Bradenton-Venice, FL MSA'              => 'Bradenton-Sarasota-Venice, FL MSA',
        'Lakeland, FL MSA'                               => 'Lakeland-Winter Haven, FL MSA',
        'Louisville-Jefferson County, KY-IN MSA'         => 'Louisville/Jefferson County, KY-IN MSA',
        'Bismarck-Mandan MSA'                            => 'Bismarck, ND MSA',
        # ' MSA'               => ' MSA',
      }
      metro.metro_name = fix_msa_names[metro.metro_name] || metro.metro_name
      @all_metros << metro
    end
    @all_metros
  end
end

# #
# CityMetro.load_cities_to_metros(CITIES_TO_METROS_CENSUS_FILENAME) # Create cities_to_metros mapping from raw file
# #
# MetropolitanArea.load_tsv                                         # Create cities_to_metros mapping from raw file

# Double check newspapers against cities_to_metros
badcities = []
NEWSPAPER_CIRCS.each do |paper, info|
  rank, circ, _, _, _, _, st, city = info
  if !CityMetro.cities_to_metros.include?([st, city])
    puts "  ['%s', %-21s]  => %-21s #%s" % [st, "'#{city}'", "'#{city}',", rank ]
  end
end

#
# Double check cities_to_metros against all_metros
#
CityMetro.cities_to_metros.each do |st_city, city_metro|
  next unless city_metro
  metro = MetropolitanArea.find_by_name(city_metro.metro_name)
  next if (city_metro.metro_stature =~ /uSA|NECTA/) || (city_metro.st == 'PR')
  if (!metro)
    puts "# missing MSA %2s %-30s %s %s" % [st_city[0], st_city[1], city_metro.metro_stature, city_metro.metro_name]
    next
  end
  city_metro.merge! metro
end

#
# Save results
#
CityMetro.dump                                                    # Save cities_to_metros
MetropolitanArea.dump                                             # Save all_metros

# Cruft
# detect hyphenated special cases
# if city =~ /^(.*)(?:-|\/)(.*)$/ then puts "  ['%s', %-30s] => %-21s" % [st, "'#{city}'", "'#{$1}'," ] end
# p [ CITY_FIXER[[st, city]], st, city_st, city ] if (city =~ /nash/i)
# cities_to_metros.find_all{|cs, info| cs[0] == 'NY'}.each{|cs, info| p [cs, info]}
