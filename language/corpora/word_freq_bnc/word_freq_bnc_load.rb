#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'imw' ; include IMW
require 'imw/extract/line_parser'
require 'word_freq_bnc_models'
require 'imw/utils/extensions/typed_struct'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup_remote_connection IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_language_corpora_word_freq' })
HeadWord.auto_upgrade!
Lemma.auto_upgrade!
WordStat.auto_upgrade!
LogLikelihood.auto_upgrade!

# ALTER TABLE `imw_language_corpora_word_freq`.`lemmas` 
#  MODIFY COLUMN `encoded` VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
#  MODIFY COLUMN `text`    VARCHAR(100) CHARACTER SET utf8  COLLATE utf8_bin  NOT NULL;
# ALTER TABLE `imw_language_corpora_word_freq`.`head_words` 
#  MODIFY COLUMN `encoded` VARCHAR(100) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
#  MODIFY COLUMN `text`    VARCHAR(100) CHARACTER SET utf8  COLLATE utf8_bin  NOT NULL;

class RawWordFreq < TypedStruct.new(
    [:context, :corpus, :head, :pos,    :lemma, :freq,    :range,    :disp, ],
    [nil,      nil,     nil,   :to_sym, nil,    :to_f,    :to_f,     :to_f, ])
  def initialize(*vals)
    super :all, *vals
    self.remap!
  end
end


files_list = [
  # [ [:head, :pos, :lemma, :freq_sp, :range_sp, :disp_sp, :ll_sign_sp_wr, :log_lkhd_sp_wr, :freq_wr, :range_wr, :disp_wr], 'ripd/2_1_spokenvwritten_alpha.txt', ],
  # [ [:head, :pos, :lemma, :freq_co, :range_co, :disp_co, :ll_sign_co_to, :log_lkhd_co_to, :freq_to, :range_to, :disp_to], 'ripd/3_1_demogvcg_alpha.txt', ],
  # [ [:head, :pos, :lemma, :freq_im, :range_im, :disp_im, :ll_sign_im_in, :log_lkhd_im_in, :freq_in, :range_in, :disp_in], 'ripd/4_1_imagvinform_alpha.txt', ],
  # [ RawWordFreq, 'ripd/1_1_all_fullalpha.txt', ],
  # [ RawWordFreq, 'rawd/1_1_all_fullalpha-40k.txt', ],
  [   RawWordFreq, 'rawd/1_1_all_fullalpha-200.txt', ],
]

def process_files files_list
  files_list.each do |factory, file_in|
    banner "Munging #{file_in}.  This may take several minutes."
    wf_parser = LineOrientedFileParser.new :skip_head => 2, :factory => false
    last_headword_seen = nil
    wf_parser.parse(File.open(file_in)) do |line|
      track_count :lines
      # raw record
      vals = [:bnc] + (line.chomp.split("\t")[1..-1])
      record = factory.new(*vals)
      # stuff into DB
      if record.head != '@'
        word = last_headword_seen = HeadWord.make(record)
      else
        word = Lemma.make(last_headword_seen, record)
      end
      word_stat = WordStat.make(word, record)
    end
  end
end

#
# Do it
# 
process_files files_list

# def build_head_lemmas_tree heads, lemmas
#   words = { }
#   heads.each  do |h_tag, info|
#     words[h_tag] = { "head" => info }
#   end
#   lemmas.each do |l_tag, info|
#     h_tag = info[:tag]
#     if (!words[h_tag]) then warn "headless lemma #{[h_tag, info].to_json}"; next; end
#     (words[h_tag]["lemmas"]||=[]).push info
#   end
#   words
# end
# 
# #
# # process files
# #
# def process_files files_list
#   fields_all = EXTRA_FIELDS
#   files_list.each do |fields, file_in|
#     announce "Munging #{file_in}.  This may take several minutes."
#     heads, lemmas = parse_all_wordfreq_file file_in, fields, heads, lemmas
#     fields_all = (fields + fields_all).uniq
#   end
#   announce "done!"
#   # csv dump
#   [ [:head, heads], [:lemmas, lemmas] ].each do |tbl_name, tbl|
#     out_file = "#{OUT_DIR}/word_freq_bnc-#{tbl_name}.csv"
#     announce "dumping to #{out_file}"
#     dump_table out_file, fields_all, tbl.sort_by{ |tag,row| tag.downcase }.map{ |tag,row| row }
#   end
#   # yaml dump
#   announce "building tree structure"
#   words = build_head_lemmas_tree heads, lemmas
#   out_file = "#{OUT_DIR}/word_freq_bnc-all.yaml"
#   announce "dumping to #{out_file}"
#   dump_all_yaml out_file, fields_all, words
# end
# 

# #
# def mk_lemma fields, headword, *vals
#   lemma = {}
#   fields.zip(vals){ |k,v| lemma[k]=v }
#   lemma[:head] = headword[:head_orig]    # Take from head word (head/orig gets fixed by fix_vals)
#   lemma[:pos]  = headword[:pos]          # (replacing the dummy '@'s)
#   fix_vals lemma
# end
# def mk_head  fields, *vals
#   head_obj = {}
#   fields.zip(vals){ |k,v| head_obj[k]=v }
#   head_obj.delete :lemma
#   fix_vals head_obj
# end
# def append_to_delimited list, str, sep
#   list = (list ? list+sep : '') + str
# end
# # tracks all the lemmas belonging to this headword
# def push_lemma_onto_head head, lemma
#   (head[:lemmas]      ||=[]).push lemma[:lemma]
#   (head[:lemmas_orig] ||=[]).push lemma[:lemma_orig]
#   head[:lemmas].uniq! ; head[:lemmas_orig].uniq!
# end


# #
# # Grok BNC files and extract headword/lemma structures
# #
# def parse_all_wordfreq_file file_in, fields, heads, lemmas
#   _reps = 0; curr = ''; tag = ''
#   File.open(file_in) do |f|
#     f.readline() ; f.readline() # throw away the header and the following blank line
#     f.readlines.each do |line|
#       _, head, *vals = line.chomp.split("\t")    
#       if head != "@" # Headword, not lemma
#         curr = RawWordFreq.new(head, *vals)
#       end
#     end
#   end
#   [heads, lemmas]
# end
# 
# 
# 
# 
#       # lemma  = mk_lemma(fields, curr, head, *vals)          # lemma
#       # push_lemma_onto_head heads[curr[:tag]], lemma         # tell headword about new lemma
#       # (lemmas[lemma[:tag_lemma]]||={}).merge! lemma
#       # _reps += 1 ; puts "#{Time.now} parsed #{_reps/1000}k of ~800k" if (_reps % 10_000 == 0)
