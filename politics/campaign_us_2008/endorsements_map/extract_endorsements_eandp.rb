#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'yaml'
require 'xmlsimple'
require 'imw/utils/extensions/core'
require 'active_support'
require 'action_view/helpers/number_helper'; include ActionView::Helpers::NumberHelper
#
require 'lib/state_abbreviations'
require 'lib/endorsement'
#
# Take the Editor & Publisher list of endorsements, extracting
#   newspaper_name => prez, circ_08, city_ep, st_ep
#

PRESIDENTS = {
  'GHW BUSH'            => 'GHWBush',
  'GEORGE W. BUSH'      => 'Bush',
  'AL GORE'             => 'Gore',
  'BARACK OBAMA'        => 'Obama',
  'JOHN McCAIN'         => 'McCain',
  'CLINTON'             => 'Clinton',
  'BOB DOLE'            => 'Dole',
  'DOLE'                => 'Dole',
  'ROSS PEROT'          => 'Perot',
  nil                   => '',
  'K'                   => 'Kerry',
  'B'                   => 'Bush',
  'N'                   => 'none',
}

ENDORSEMENT_RE = {
  1992 => /^([A-Z][a-z].+)?$/,
  1996 => /^([A-Z][a-z].+)?$/,
  2000 => /^([A-Z][a-z].+)?$/,
  2008 => /^([^\:]*?)(?::? \((B|K|N|N\/A|)\))?:? *([0-9,]+)?$/,
}

def parse_ep_endorsements(raw_filename, endorsement_re, year)
  endorsements = {}
  File.open(raw_filename) do |f|
    # 3.times do f.readline end                   # Skip first three lines
    prez  = ''; city  = ''; st = ''             # Initial conditions
    f.each do |l|
      l.chomp!; l.strip!
      l.gsub!(/>>+/, '')                        # 'newly-added' designator
      l.gsub!(/^#.*$/, '')                      # comment
      l.gsub!(/Foster.*s Daily/, 'Foster\'s Daily') # cruft
      next if l =~ /^\s*$/                      # blank
      #
      case
      when l =~ /(?:daily newspapers total|daily circulation total)/ then next
      when PRESIDENTS.include?(l)
        prez = PRESIDENTS[l]
      when (l.upcase == l) && (l =~ /[A-Z]+/)
        state = l.upcase.gsub(/\s+\([0-9]+\)$/, '')
        st = STATE_ABBREVIATIONS[state] # un-abbreviate
        warn "Confused about state #{state} from #{l}" unless st
      else
        m = endorsement_re.match(l)
        if m
          paper, prez_prev, circ = m.captures.map{|e| (e||'').strip};
          # fix prez
          prez_prev = PRESIDENTS[prez_prev]
          # fix circ
          circ   = (circ||'').gsub(/[^0-9]/,'').to_i
          # parse out city, get location
          paper, city = fix_city_and_paper(paper, state)
          warn "Badness '#{l}'" if paper.blank?
          # ok, you're endorsed
          hsh = { :paper => paper, :st => st, :city => city }
          Endorsement.set_prez hsh, year, prez
          Endorsement.set_prez hsh, year-4, prez_prev unless (prez_prev.blank?)
          # puts [hsh, l].to_json
          endorsements[paper] = hsh
        else
          puts "Bad Line '#{l}'"
        end
      end
    end
  end
  endorsements
end

#
# Handle cases like << Union Leader (Manchester) (B): 51,782 >>
#
def fix_city_and_paper(orig_paper, state)
  # extract embedded city info
  case
  when orig_paper =~ /^(.*) \((.*)\)(.*)/  then  paper, city = [$1+($3||''), $2]
  when orig_paper =~ /^(.*), ([A-Za-z]+.*)$/  then  paper, city = [$1, $2]
  else
    paper = orig_paper
  end
  paper.gsub!(/^The\s+/i, '')
  paper.gsub!(/\s+&\s+/, ' and ')
  city = { 
    'Bryan-College Station'     => 'Bryan',
    'Neptune'                   => 'Asbury Park',
    'Wilkes Barre'              => 'Wilkes-Barre',    
    'Ft. Lauderdale'            => 'Fort Lauderdale',
    'Champaign-Urbana'          => 'Champaign',
    'West Lafayette'            => 'Lafayette',
    'LaCrosse'                  => 'La Crosse',
    'Lake County-Willoughby'    => 'Willoughby'
  }[city] || city
  # Some special cases
  # Delaware County Daily Times is in Primos -- but that's basically philadelphia
  # Gannett Sunburban Newspapers is many papers, based in White Plains, NY
  city, paper = { 
    ['Arlington', 'Daily Herald']   => ['Arlington Heights', 'Daily Herald'],
    ['Bryan',     'Eagle']          => ['Bryan',             'Bryan-College Station Eagle'],
  }[ [city, paper] ] || [city, paper]
  keep_city = ['Daily News', 'Sun', 'Record', 'News Journal', 'Times', 'Spokesman-Review', 'Chronicle', 'Courier']
  case
  when !city.blank? && keep_city.include?(paper) then paper = "#{paper} (#{city})"
  when (paper == 'Kenne Sentinel')                      then city, paper = 'Keene', 'Keene Sentinel'  
  when (paper =~ /Record.*Bergen/)                      then city, paper = 'Hackensack', 'Record'  
  when (paper =~ /Spokesman.*Review/) && (orig_paper =~ /Spokane/) then paper = "Spokesman-Review (Spokane)"
  end
  # puts "%-30s %-30s %-50s" % [paper, city, orig_paper] if orig_paper =~ /daily.*news/i
  [paper, city]
end

#
# Extract the endorsements
#
[1992, 1996, 2000, 2008].each do |year|
  raw_filename = "ripd/endorsements_#{year}/endorsements-raw-#{year}.txt"
  out_filename = "data/endorsements_#{year}_eandp.yaml"
  print "Extracting E&P year #{year} into #{out_filename}"
  endorsements = parse_ep_endorsements(raw_filename, ENDORSEMENT_RE[year], year)
  puts "... got #{endorsements.length} papers"
  YAML.dump(endorsements, File.open(out_filename, 'w'))
end

