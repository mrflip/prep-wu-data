#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'imw'
# require 'cgi'
require 'htmlentities'; $KCODE = 'u'
require 'word_freq_bnc_models'
require 'htmlentities/expanded'

# 2_1 160 head PoS lemma  FrSp    RaSp    DiSp +- LLSpWr  FrWr  RaWr  DiWr
# 3_1 120 head PoS lemma  FrCo    RaCo    DiDe +- LLCoTO  FrTO  RaTO  DiCG
# 4_1     head PoS lemma  FrIm    RaIm    DiIm +- LLImIn  FrIn  RaIn  DiIn

files_list = [
    [ [:head, :pos, :lemma, :freq_sp, :range_sp, :disp_sp, :ll_sign_sp_wr, :log_lkhd_sp_wr, :freq_wr, :range_wr, :disp_wr], 'ripd/2_1_spokenvwritten_alpha.txt', ],
    [ [:head, :pos, :lemma, :freq_co, :range_co, :disp_co, :ll_sign_co_to, :log_lkhd_co_to, :freq_to, :range_to, :disp_to], 'ripd/3_1_demogvcg_alpha.txt', ],
    [ [:head, :pos, :lemma, :freq_im, :range_im, :disp_im, :ll_sign_im_in, :log_lkhd_im_in, :freq_in, :range_in, :disp_in], 'ripd/4_1_imagvinform_alpha.txt', ],
    [ [:head, :pos, :lemma, :freq,    :range,    :disp],                                                       'ripd/1_1_all_fullalpha.txt', ],
#    [ [:head, :pos, :lemma, :freq,    :range,    :disp],                                                       'foo.txt', ],
]
OUT_DIR      = './fixd'
LEMMA_SEP    = '^'
EXTRA_FIELDS = [:tag, :head_orig, :tag_lemma, :lemma_orig, :lemmas, :lemmas_orig]



def build_head_lemmas_tree heads, lemmas
  words = { }
  heads.each  do |h_tag, info|
    words[h_tag] = { "head" => info }
  end
  lemmas.each do |l_tag, info|
    h_tag = info[:tag]
    if (!words[h_tag]) then warn "headless lemma #{[h_tag, info].to_json}"; next; end
    (words[h_tag]["lemmas"]||=[]).push info
  end
  words
end

#
# process files
#
def process_files files_list
  fields_all = EXTRA_FIELDS
  files_list.each do |fields, file_in|
    announce "Munging #{file_in}.  This may take several minutes."
    heads, lemmas = parse_all_wordfreq_file file_in, fields, heads, lemmas
    fields_all = (fields + fields_all).uniq
  end
  announce "done!"
  # csv dump
  [ [:head, heads], [:lemmas, lemmas] ].each do |tbl_name, tbl|
    out_file = "#{OUT_DIR}/word_freq_bnc-#{tbl_name}.csv"
    announce "dumping to #{out_file}"
    dump_table out_file, fields_all, tbl.sort_by{ |tag,row| tag.downcase }.map{ |tag,row| row }
  end
  # yaml dump
  announce "building tree structure"
  words = build_head_lemmas_tree heads, lemmas
  out_file = "#{OUT_DIR}/word_freq_bnc-all.yaml"
  announce "dumping to #{out_file}"
  dump_all_yaml out_file, fields_all, words
end

#
# Headword / Lemma structures
#
# KLUDGE -- we're going to stuff these extra entries into the SGML mapping --
# see notes on 'uncaught entities'
HTMLEntities::MAPPINGS['expanded'].merge!({
    "bquo"     => 0x201c,
    "ft"       => 0x0027,
    "ins"      => 0x0022,
    "rehy"     => 0x00ad,
    "shilling" => 0x002f,
    "formula"  => 0x222e,
  })
$entity_decoder = HTMLEntities.new(:expanded)
def decode_str(str)
  # found during processing: only 3, so why be clever.
  str = str.gsub(/&frac17;/, '1/7')
  str.gsub!(/&frac19;/, '1/9')
  str.gsub!(/4&frac47;/,'4 4/7')
  str = $entity_decoder.decode(str)
end


#
#
require "special_cases"
def fix_vals hsh
  hsh.keys.each do |f|
    case
    when f.to_s =~ /^(log_lkhd|disp).*/  then hsh[f] = hsh[f].to_f
    when f.to_s =~ /^(freq|range).*/     then hsh[f] = hsh[f].to_i
    when f == :head
      head_orig = hsh[:head]
      pos       = hsh[:pos]
      if REMAP_HEADS.include?( [head_orig, pos] )
        head_orig, pos = REMAP_HEADS[ [head_orig, pos] ]
        hsh[:pos] = pos
      end
      #no conflict here because :pos isn't changed except in this block.
      hsh[:tag]       = "#{head_orig}_#{hsh[:pos]}"
      hsh[:head_orig] = head_orig
      hsh[:head]      = decode_str(head_orig||'')
    when f == :lemma
      lemma_orig = hsh[:lemma]
      if REMAP_HEADS.include?( [lemma_orig, hsh[:pos]] )
        lemma_orig, hsh[:pos] = REMAP_HEADS[ [lemma_orig, hsh[:pos]] ]
        hsh[:pos] = pos
      end
      hsh[:tag_lemma]  = "#{hsh[:tag]}_#{lemma_orig}"
      hsh[:lemma_orig] = lemma_orig
      hsh[:lemma]      = decode_str(lemma_orig||'')
    end
  end
  hsh
end
#
def mk_lemma fields, headword, *vals
  lemma = {}
  fields.zip(vals){ |k,v| lemma[k]=v }
  lemma[:head] = headword[:head_orig]    # Take from head word (head/orig gets fixed by fix_vals)
  lemma[:pos]  = headword[:pos]          # (replacing the dummy '@'s)
  fix_vals lemma
end
def mk_head  fields, *vals
  head_obj = {}
  fields.zip(vals){ |k,v| head_obj[k]=v }
  head_obj.delete :lemma
  fix_vals head_obj
end
def append_to_delimited list, str, sep
  list = (list ? list+sep : '') + str
end
# tracks all the lemmas belonging to this headword
def push_lemma_onto_head head, lemma
  (head[:lemmas]      ||=[]).push lemma[:lemma]
  (head[:lemmas_orig] ||=[]).push lemma[:lemma_orig]
  head[:lemmas].uniq! ; head[:lemmas_orig].uniq!
end

#
# Grok BNC files and extract headword/lemma structures
#
def parse_all_wordfreq_file file_in, fields, heads, lemmas
  _reps = 0; curr = ''; tag = ''
  File.open(file_in) do |f|
    f.readline() # throw away the header
    f.readline() # and the following blank line
    f.readlines.each do |line|
      _, head, *vals = line.chomp.split("\t")
      # toss on right pile
      unless head == "@"
        curr       = mk_head(fields, head, *vals)           # headword
        (heads[curr[:tag]]||={}).merge! curr
        vals[1] = curr[:head_orig]                          # make single headword its own lemma
      end
      lemma  = mk_lemma(fields, curr, head, *vals)          # lemma
      push_lemma_onto_head heads[curr[:tag]], lemma         # tell headword about new lemma
      (lemmas[lemma[:tag_lemma]]||={}).merge! lemma
      _reps += 1 ; puts "#{Time.now} parsed #{_reps/1000}k of ~800k" if (_reps % 10_000 == 0)
    end
  end
  [heads, lemmas]
end


#
# Do it
# 
process_files files_list
