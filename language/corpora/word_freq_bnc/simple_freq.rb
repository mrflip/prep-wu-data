#!/usr/bin/env ruby
# -*- coding: mule-utf-8 -*-
require 'rubygems'
require 'YAML'
require 'JSON'
require 'fastercsv'
require 'imw/utils'; include IMW
$KCODE = 'u'

IMW.verbose = false

LEMMAS_FILE_IN   = './temp/word_freq_bnc-reduced-4000.csv'
CODEBOX_FILE_IN  = './temp/freq100-codebox.tsv'
lemma_keys = [:lemmarank,:head, :pos, :lemma, :freq, :disp, :freq_sp, :freq_wr, :tag, :head_orig, :tag_lemma, :rank]

#
# Load table to hash.
#
Lemma = Struct.new(*lemma_keys)
def csv_load_lemmas lemmas_file_in
  lemmas = {}
  count  = 0
  # silently swallows header, so no need to explicitly nil it.
  FasterCSV.open(lemmas_file_in, 'r').each do |row|
    track_count :lemmas, 400
    lemma = Lemma.new(*row)
    [:freq, :freq_sp, :freq_wr].each do |attr| lemma[attr] = lemma[attr].to_i  end
    lemmas[lemma[:tag_lemma]] = lemma
  end
  lemmas
end


def lexwords(string)
  string = string.gsub(/\*/,'').gsub(/let's/,'let us')
  corrections = {
    "'ve"         => "have",
    "'re"         => "are",
    "'nt"         => "not",
    "n't"         => "not",
    "'ll"         => "will",
    "'m"          => "him",
    "'d"          => "would",
    "no."         => "number",
    "pp."         => "page",
    "ff."         => "pages",
    "let's"       => "let us"
  }
  # should "as well as" count for one or for two occurrences of 'as'?
  # if "one", then "string.split(/\s/).uniq. ...."
  string.split(/\s/).map{|wd| corrections.fetch(wd, wd) }
end

def combine_lex lex1, lex2
  return (lex1 || lex2) unless (lex1 && lex2)
  lex1.freq   += lex2.freq
  lex1.lemmas  = (lex1.lemmas + lex2.lemmas).uniq
  lex1.heads   = (lex1.heads  + lex2.heads ).uniq
  lex1
end

Lex = Struct.new(:lex_rank, :wd, :lemmas, :heads, *lemma_keys)
def sum_lexical_freqs lemmas, field
  lexes = { }
  lemmas.sort_by{|t,l| -l.freq }.each do |tag_lemma, lemma|
    lexwords(lemma[field]).each do |wd|
      newlex    = Lex.new(nil, wd, [lexwords(lemma.lemma).join(" ")], [lexwords(lemma.head).join(" ")], *lemma)
      lexes[wd] = combine_lex lexes[wd], newlex
    end
  end
  lexes
end

def index_structs hsh, index_key, sort_key, dir=1, start=0
  sorted = hsh.sort_by{ |k,val| dir*val[sort_key] }
  idx = start
  sorted.each do |k, val|
    hsh[k][index_key] = idx
    idx += 1
  end
end

RankedWord = Struct.new(:rank, :wd)
def load_ranked_freqs filename
  File.open(filename).readlines.map do |line|
    rk, wd = line.chomp.split("\t")
    RankedWord.new(rk.to_i, wd)
  end
end


lemmas      = csv_load_lemmas LEMMAS_FILE_IN
index_structs lemmas, :rank, :freq, -1, 1
lemma_lexes = sum_lexical_freqs lemmas, :lemma
head_lexes  = sum_lexical_freqs lemmas, :head
head_lexes['be'] = combine_lex head_lexes['be'], head_lexes['is']; head_lexes.delete('is')
index_structs lemma_lexes, :lex_rank, :freq, -1, 1
index_structs head_lexes,  :lex_rank, :freq, -1, 1
codebox_ranked_words = load_ranked_freqs(CODEBOX_FILE_IN)

# 21      18      2       6644    42277   be      be      be      be                                                                                              is,was,be,are,were,'s,been,being,'re,'m,am
# 7       9       1776    10028   46      is      that is be      that is                                                                                         that is
# 21      18      2       6644    42323   be      be      be      be,that is                                                                                      is,was,be,are,were,'s,been,being,'re,'m,am,that is


# codebox_ranked_words.each do |rw|
#   ll = lemma_lexes[rw.wd]
#   puts [rw.rank, ll.lex_rank, ll.freq, rw.wd, ll.head].join("\t")
# end

# lemma_lexes.values.sort_by{ |ll| -ll.freq }.each do |ll|
#   rw = codebox_ranked_words.find{|rw| rw.wd == ll.wd }
#   hl = head_lexes[ll.head] || Lex.new()
#   next unless (rw || (ll.lex_rank <= 101) || (hl.lex_rank && hl.lex_rank <= 101))
#   puts [(rw ? rw.rank : 101), ll.lex_rank, hl.lex_rank, ll.freq, hl.freq, ll.wd, ll.head, ll.heads.join(','), ll.lemmas.join(','), ].join("\t")
# end

puts %w[cbox_rk              lemm_rk      head_rk     l_freq   h_freq   wd  head     lemma1    heads        lemmas].join("\t")
head_lexes.values.sort_by{ |hl| -hl.freq }.each do |hl|
  wd = hl.wd
  rw = codebox_ranked_words.find{|rw| rw.wd == wd }
  ll = lemma_lexes[wd] || Lex.new()
  next unless (rw || (ll.lex_rank && ll.lex_rank <= 101) || (hl.lex_rank && hl.lex_rank <= 101))
  puts [(rw ? rw.rank : ''), ll.lex_rank, hl.lex_rank, ll.freq, hl.freq, wd, hl.head, ll.head, "%-90s"%hl.heads.join(','), hl.lemmas.join(','), ].join("\t")
end


puts %w[cbox_rk              lemm_rk      head_rk     l_freq   h_freq   wd  head     lemma1    heads        lemmas].join("\t")
head_lexes.values.sort_by{ |hl| -hl.freq }[0..99].each_with_index do |hl,i|
  wd = hl.wd
  rw = codebox_ranked_words.find{|rw| rw.wd == wd }
  ll = lemma_lexes[wd] || Lex.new()
  print ("%-32s" % "'#{hl.lemmas.join(", ")}',") + (((i+1) % 4 == 0) ? "\n" : '')
end
