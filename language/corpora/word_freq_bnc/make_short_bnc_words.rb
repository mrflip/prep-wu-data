#!/usr/bin/env ruby
# -*- coding: mule-utf-8 -*-
require "rubygems"
require "YAML"
require "fastercsv"
require "utils"

#, :headers => :first_row

#
# Load table to hash.
#
def csv_load_words words_file_in, key, fields_all, fields_want
  words = {}
  _reps = 0
  field_idxs = fields_want.map{ |i| fields_all.index(i) }
  # silently swallows header, so no need to explicitly nil it.
  FasterCSV.open(words_file_in, 'r').each do |row|
    word = Hash.zip(fields_want, row.values_at(*field_idxs))
    words[word[key]] = word
    _reps += 1 ; puts "#{Time.now} parsed #{_reps/1000}k" if (_reps % 10_000 == 0)
  end
  words
end

#
# Dump as flat table
#
def csv_dump_words words_file_out, fields, table
  _reps = 0
  FasterCSV.open(words_file_out, "w") do |csv|
    csv << fields
    table.each do |row|
      csv << row.values_at(*fields)
      _reps += 1 ; puts "#{Time.now} parsed #{_reps/1000}k" if (_reps % 10_000 == 0)
    end
  end
end


#
def variants_from_heads heads
  words = { }
  heads.each do |tag, head|
    head[:tag_lemma] = "#{head[:tag]}_#{head[:head_orig]}"
    # head[:lemmas]    = head[:lemma] if head[:lemma]
    head[:lemma]     = head[:head]
    words[head[:tag_lemma]] = head
  end
  words
end
def merge_heads_and_lemmas heads, lemmas
  words = { } # variants_from_heads heads
  lemmas.each do |tag_lemma, lemma|
    (words[tag_lemma]||={}).merge! lemma
  end
  words
end

BNC_FIELDS_ALL   = [:head,:pos,:lemma,:freq,:range,:disp,:freq_im,:range_im,:disp_im,:ll_sign_im_in,:log_lkhd_im_in,:freq_in,:range_in,:disp_in,:freq_co,:range_co,:disp_co,:ll_sign_co_to,:log_lkhd_co_to,:freq_to,:range_to,:disp_to,:freq_sp,:range_sp,:disp_sp,:ll_sign_sp_wr,:log_lkhd_sp_wr,:freq_wr,:range_wr,:disp_wr,:tag,:head_orig,:tag_lemma,:lemma_orig,:lemmas,:lemmas_orig]
BNC_FIELDS_WANT  = [:head, :pos, :lemma, :freq, :disp, :freq_sp, :freq_wr, :tag, :head_orig, :tag_lemma]
#BNC_FIELDS_ALL  = [:head,:pos,:lemma,:freq_im,:range_im,:disp_im,:ll_sign_im_in,:log_lkhd_im_in,:freq_in,:range_in,:disp_in,:freq_co,:range_co,:disp_co,:ll_sign_co_to,:log_lkhd_co_to,:freq_to,:range_to,:disp_to,:freq_sp,:range_sp,:disp_sp,:ll_sign_sp_wr,:log_lkhd_sp_wr,:freq_wr,:range_wr,:disp_wr,:tag,:head_orig,:tag_lemma,:lemma_orig,:lemmas,:lemmas_orig]
#BNC_FIELDS_WANT = [:head, :pos, :lemma, :freq_sp, :freq_wr, :tag, :head_orig, :tag_lemma]
in_file_base   = "./fixd/word_freq_bnc"
words_file_out = "./fixd/word_freq_bnc-reduced.csv"
# in_file_base   = "./fixd/short"
# words_file_out = "./fixd/short-reduced.csv"

heads = []
# heads_file_in = in_file_base+'-head.csv'
# announce "Reading #{heads_file_in}"

lemmas_file_in = in_file_base+'-lemmas.csv'
announce "Reading #{lemmas_file_in}"
lemmas  = csv_load_words lemmas_file_in, :tag_lemma, BNC_FIELDS_ALL, BNC_FIELDS_WANT

announce "merging lemmas into heads"
words = merge_heads_and_lemmas heads, lemmas

announce "Writing #{words_file_out}"
sorted_words = words.values.sort_by{ |wd| -(wd[:freq]||wd[:freq_wr]||-1).to_i }
csv_dump_words words_file_out, BNC_FIELDS_WANT, sorted_words
announce "done!"



# 0  head,pos,lemma,freq,range,disp,  5
# 6  freq_im,range_im,disp_im,ll_sign_im_in,log_lkhd_im_in,freq_in,range_in,disp_in, 13
# 14 freq_co,range_co,disp_co,ll_sign_co_to,log_lkhd_co_to,freq_to,range_to,disp_to, 21
# 22 freq_sp,range_sp,disp_sp,ll_sign_sp_wr,log_lkhd_sp_wr,freq_wr,range_wr,disp_wr, 29
# 30 tag,head_orig,tag_lemma,lemma_orig,lemmas,lemmas_orig 35

# 0  head,pos,lemma, 2
# 3  freq_im,range_im,disp_im,ll_sign_im_in,log_lkhd_im_in,freq_in,range_in,disp_in, 10
# 11 freq_co,range_co,disp_co,ll_sign_co_to,log_lkhd_co_to,freq_to,range_to,disp_to, 18
# 19 freq_sp,range_sp,disp_sp,ll_sign_sp_wr,log_lkhd_sp_wr,freq_wr,range_wr,disp_wr, 26
# 27 tag,head_orig,tag_lemma,lemma_orig,lemmas,lemmas_orig 32


# == Fixed by hand ==
#
# let's                 Verb    (changed pos to VMod in 2_1, 3_1, 4_1)
# used (to)             VMod    (changed VMod sense to 'used\tVMod' in 1_1_alpha, 1_2, 2_1, 3_1, 3_2, 4_2)
# &                     Conj    4 & => &amp;

# == Case difference ==
# I                     Pron    1 I
# American              Adj     1 A
# British               Adj     1 B
# English               Adj     1 E
# European              Adj     1 E
# air                   NoC     1 a
# chairman              NoC     1 Chairman => chairman
# Christmas             NoC     1 C
# councillor            NoC     1 c
# doctor                NoC     1 d
# father                NoC     1, 3 f
# field                 NoC     1 f
# home                  NoC     1 h
# king                  NoC     king
# leader                NoC     leader
# lord                  NoC     lord
# mother                NoC     mother
# Mr                    NoC     Mr
# Mrs                   NoC     Mrs
# place                 NoC     place
# president             NoC     president
# Richard               NoP     Richard
# road                  NoC     road
# sir                   NoC     sir
# sister                NoC     sister
# street                NoC     street
# town                  NoC     town

# == turned all underscores '_' into space ' ' in 1_1 ==
# a bit                 Adv
# a little              Adv
# according to          Prep
# and so on             Adv
# as if                 Conj
# as well as            Prep
# as well               Adv
# at all                Adv
# at least              Adv
# away from             Prep
# because of            Prep
# each other            Pron
# for example           Adv
# in terms of           Prep
# of course             Adv
# officer               NoC
# on to                 Prep
# out of                Prep
# over there            Adv
# per cent              NoC
# rather than           Prep
# so that               Conj
# sort of               Adv
# such as               Prep
# up to                 Prep
