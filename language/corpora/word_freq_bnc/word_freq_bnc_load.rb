#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'imw' ; include IMW
require 'imw/extract/line_parser'
require 'imw/utils/extensions/typed_struct'
require 'fastercsv'
as_dset(__FILE__)

# require 'word_freq_bnc_models'
# DataMapper::Logger.new(STDOUT, :debug)
# DataMapper.setup_remote_connection IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_language_corpora_word_freq' })
# HeadWord.auto_upgrade!
# Lemma.auto_upgrade!
# WordStat.auto_upgrade!
# LogLikelihood.auto_upgrade!

def decode encoded
  encoded
end

class RawWordFreq < TypedStruct.new(
    [:corpus, :head, :pos,  :lemma, :freq_1, :range_1, :disp_1, :ll_sign, :ll_val, :freq_2, :range_2, :disp_2, ],
    [nil,     nil,   nil,   nil,    :to_f,   :to_f,    :to_f,   nil,      :to_f,     :to_f,    :to_f,   ])
  def initialize(*vals)
    super *vals
    self.remap!
    self.ll_sign = case self.ll_sign when '+' then 1 when '-' then -1 else nil end
  end  
  def self.new_from_line line
    self.new('bnc', *(line.chomp.split("\t")[1..-1]))
  end
  def head_arr()                values_of(:head,   :pos)         + [decode(self[:head])]  end
  def lemma_arr()               values_of(:head,   :pos, :lemma) + [decode(self[:lemma])] end
  def head_freq_arr_1(context)  values_of(:corpus,         :head,  :pos, :freq_1, :range_1, :disp_1) + [context] end
  def head_freq_arr_2(context)  values_of(:corpus,         :head,  :pos, :freq_2, :range_2, :disp_2) + [context] end
  def head_ll_arr(context)      values_of(:corpus,         :head,  :pos, :ll_val, :ll_sign)          + [context] end
  def lemma_freq_arr_1(context) values_of(:corpus, :lemma, :head,  :pos, :freq_1, :range_1, :disp_1) + [context] end
  def lemma_freq_arr_2(context) values_of(:corpus, :lemma, :head,  :pos, :freq_2, :range_2, :disp_2) + [context] end
  def lemma_ll_arr(context)     values_of(:corpus, :lemma, :head,  :pos, :ll_val, :ll_sign)          + [context] end
  def has_part2?() freq_2.to_s != '' end
  def has_ll?()    ll_val.to_s != '' end
end

files_list = [
  ['rawd/1_1_all_fullalpha-200.txt',     'all',           false],
  ['ripd/2_1_spokenvwritten_alpha.txt',  'spoken',        'written'],
  ['ripd/3_1_demogvcg_alpha.txt',        'ctxt_oriented', 'task_oriented'],
  ['ripd/4_1_imagvinform_alpha.txt',     'imaginative',   'informative'],
  ['rawd/1_1_all_fullalpha-40k.txt',     'all',           false],
  ['ripd/1_1_all_fullalpha.txt',         'all',           false],
]

def open_csv_files file_in
  file_root = File.basename(file_in, '.txt')
  [:heads,  :head_word_stats,  :head_lls, :lemmas, :lemma_word_stats, :lemma_lls, ].map do |type|
    FasterCSV.open(path_to(:fixd, "%s_%s.csv"%[file_root,type]), "w")
  end
end

def process_files files_list
  wf_parser = LineOrientedFileParser.new :skip_head => 2, :factory => false
  files_list.each do |file_in, context1, context2|
    banner "Munging #{file_in}.  This may take several minutes."
    # output file
    heads_csv,  head_word_stats_csv,  head_lls_csv,
    lemmas_csv, lemma_word_stats_csv, lemma_lls_csv = open_csv_files file_in  
    # track headword across subsequent lemmas
    last_headword_seen = nil            
    wf_parser.parse(File.open(file_in)) do |line| track_count(:lines)
      record = RawWordFreq.new_from_line(line)
      if record.head != '@'
        last_headword_seen = record
        record[:lemma] = record[:head]
        heads_csv             << record.head_arr
        head_word_stats_csv   << record.head_freq_arr_1(context1) 
        head_word_stats_csv   << record.head_freq_arr_2(context2)  if context2
        head_lls_csv          << record.head_ll_arr(context1)      if context2
        lemmas_csv            << record.lemma_arr
        lemma_word_stats_csv  << record.lemma_freq_arr_1(context1)
        lemma_word_stats_csv  << record.lemma_freq_arr_2(context2) if context2
        lemma_lls_csv         << record.lemma_ll_arr(context1)     if context2
      else
        record[:head] = last_headword_seen[:head]
        record[:pos]  = last_headword_seen[:pos]
        lemmas_csv            << record.lemma_arr
        lemma_word_stats_csv  << record.lemma_freq_arr_1(context1)
        lemma_word_stats_csv  << record.lemma_freq_arr_2(context2) if context2
        lemma_lls_csv         << record.lemma_ll_arr(context1)     if context2
      end
    end
    [heads_csv,  head_word_stats_csv,  head_lls_csv,
    lemmas_csv, lemma_word_stats_csv, lemma_lls_csv].each{|f| f.close }
  end
end

#
# Do it
# 
process_files files_list
