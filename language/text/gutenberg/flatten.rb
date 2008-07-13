#!/usr/bin/env ruby
# -*- coding: mule-utf-8 -*-
require "rubygems"
require "activesupport"
# require "JSON"
#require "YAML"
require "fastercsv"
require "utils"

RE_TITLE        = /\*\*\*The Project Gutenberg's Etext of Shakespeare's First Folio\*\*\*/
RE_HEADER_END   = /\*END\*THE SMALL PRINT! FOR PUBLIC DOMAIN ETEXTS\*/

def nuke_symbols(line) line.gsub!(/[^\w\s]+/, '').downcase! end  # \. if breaking lines
def find_breaks(line)  line.gsub(/(\n\s*\n|\.\s+)/, ' -- ') end
def get_words(line)    line.split(/\s+/)  end
def mungeline line
  nuke_symbols line
  # find_breaks  line
  words = get_words line
end

def bank_word counts, idxs, word
  counts[word]||=0; counts[word] += 1
  idxs[word] = idxs.length if !idxs[word]
end

def chain_words chains, idxs, census, words
  prev = nil
  words.each do |word|
    if (prev.blank? || word.blank?) then prev = word; next end
    bank_word census[:counts], idxs, word
    (chains[prev]||=[]).push idxs[word]
    # (chains[prev]||=[]).push word
    prev = word
    announce_progress(census[:total]+=1, 'chained')
    # break if _reps > 100
  end
  [chains, idxs, census]
end

#
# kill all words that occured less than twice
#
def reduce_data chains, idxs, census
  # keep_counts, nuke_counts = counts.partition{ |wd,count| count < 3 }
  # #ugh. have to spin keep_counts back into an array
  # counts = { }; keep_counts.each{ |wd,ct| counts[wd] = ct }
  _reps = 0
  _wds  = 0
  wd_idx = idxs.invert

  min_count = 4

  chains.keys.each do |head|
    chains[head].reject!{ |idx| census[:counts][wd_idx[idx]] < min_count }
    announce_progress(_wds+=1, 'killed chains', 10_000)
  end

  census[:counts].keys.each do |wd|
    next unless census[:counts][wd] < min_count
    num_killed = census[:counts].delete(wd)  # kill from counts
    census[:total] -= num_killed             # debit from total
    idx = idxs.delete(wd)                    # kill from indexes
    chains.delete wd                         # kill from chain list
    announce_progress(_reps+=1, 'stripped', 1_000)
  end

  # census[:counts].keys.each do |wd|
  #   announce_progress(_wds+=1, 'considered', 10_000)
  #   next unless census[:counts][wd] < 3
  #   num_killed = census[:counts].delete(wd)  # kill from counts
  #   census[:total] -= num_killed             # debit from total
  #   idx = idxs.delete(wd)                    # kill from indexes
  #   chains.each do |head, chain|
  #     chain.delete idx                       # kill from chains
  #   end
  #   chains.delete wd
  #   announce_progress(_reps+=1, 'stripped', 500)
  # end
  [chains, idxs, census]
end


OUT_DIR = '/home/flip/ics/fixd/language/text/gutenberg'
#OUT_FILE = "#{OUT_DIR}/gutenberg_word_adjacency-all.yaml"
#OUT_FILE = "#{OUT_DIR}/gutenberg_word_adjacency.yaml"
#OUT_FILE = "#{OUT_DIR}/short-reduced.yaml"
# OUT_FILE = "#{OUT_DIR}/short.yaml"
# OUT_FILE = "#{OUT_DIR}/shakespeare_word_adjacency.yaml"
OUT_FILE = "#{OUT_DIR}/shakespeare_word_adjacency-reduced.yaml"

chains = { }
idxs   = { }
census = { :total => 0, :counts => {} }
titles = []
ARGV.each do |filename|
  announce "Munging #{filename}; #{census[:total]} words (#{idxs.length} unique) in #{chains.length} chains"
  slurp = File.open(filename).readlines.join(' ')
  # title = slurp.match(/Project Gutenberg(?:'s)? Etext\s*(?:,|of)\s*([^\*]+)\*+This file should be named/i)
  # titles << title[1].gsub(/\s+/, " ") if title
  # slurp = slurp.gsub(/\A.*?#{RE_HEADER_END}[^\n]+\n/mi, '')
  words = mungeline(slurp)
  chain_words(chains, idxs, census, words)
end

# strip low-frequency words
announce "stripping low-frequency words"
reduce_data chains, idxs, census

#
announce "Dumping to #{OUT_FILE}"
YAML.dump({
    'titles' => titles,
    'chains' => chains,
    'census' => census,
    'idxs'   => idxs.invert,
  }, File.open(OUT_FILE, 'w'))
announce "done!"


# case
# when (phase == :title) && (line =~ RE_HEADER_END) then phase = :body; next
# when (phase == :title)                            then next
# when line =~ /End of the Project Gutenberg etext/ then next
# end
# next if line.blank?
