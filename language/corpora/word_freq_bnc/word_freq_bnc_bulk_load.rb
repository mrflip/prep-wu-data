#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'imw' ; include IMW
require 'imw/extract/line_parser'
require 'imw/utils/extensions/typed_struct'
require 'imw/dataset/datamapper'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup_remote_connection IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_language_corpora_word_freq' })

def bulk_load(file_base)
  loader = [
    %Q{
        LOAD DATA INFILE "/data/fixd/language/corpora/word_freq_bnc/#{file_base}_heads.csv"
          IGNORE INTO TABLE `imw_language_corpora_word_freq`.head_words
          FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
          (`encoded`, `pos`, `text`)
    }, %Q{
        LOAD DATA INFILE "/data/fixd/language/corpora/word_freq_bnc/#{file_base}_lemmas.csv"
          IGNORE INTO TABLE `imw_language_corpora_word_freq`.raw_lemmas
          FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
          (`head_word`, `pos`, `encoded`, `text`)
    }, %Q{
        LOAD DATA INFILE "/data/fixd/language/corpora/word_freq_bnc/#{file_base}_head_word_stats.csv"
          IGNORE INTO TABLE `imw_language_corpora_word_freq`.raw_word_stats_heads
          FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
          (`corpus`, `head_word`, `pos`, `freq`, `range`, `disp`, `context`)
          SET `word_type`="HeadWord"
    }, %Q{
        LOAD DATA INFILE "/data/fixd/language/corpora/word_freq_bnc/#{file_base}_head_lls.csv"
          IGNORE INTO TABLE `imw_language_corpora_word_freq`.raw_log_likelihoods_heads
          FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
          (`corpus`, `head_word`, `pos`, `value`, `sign`, `context`)
          SET `word_type`="HeadWord"
    }, %Q{
        LOAD DATA INFILE "/data/fixd/language/corpora/word_freq_bnc/#{file_base}_lemma_word_stats.csv"
          IGNORE INTO TABLE `imw_language_corpora_word_freq`.raw_word_stats_lemmas
          FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
          (`corpus`, `lemma`, `head_word`, `pos`, `freq`, `range`, `disp`, `context`)
          SET `word_type`="Lemma"
    }, %Q{
        LOAD DATA INFILE "/data/fixd/language/corpora/word_freq_bnc/#{file_base}_lemma_lls.csv"
          IGNORE INTO TABLE `imw_language_corpora_word_freq`.raw_log_likelihoods_lemmas
          FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
          (`corpus`, `lemma`, `head_word`, `pos`, `value`, `sign`, `context`)
          SET `word_type`="Lemma"
    },
  ]

  loader.each{|query| repository(:default).adapter.execute(query) }
end

files_list = [
  '1_1_all_fullalpha-200',
  '2_1_spokenvwritten_alpha',
  '3_1_demogvcg_alpha',
  '4_1_imagvinform_alpha',
  '1_1_all_fullalpha-40k',
  '1_1_all_fullalpha',
]
files_list.each{|f| bulk_load(f) }
