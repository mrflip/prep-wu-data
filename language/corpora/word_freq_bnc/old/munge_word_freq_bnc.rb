#!/usr/bin/env ruby
# -*- coding: mule-utf-8 -*-
require 'rubygems'
require 'cgi'
require 'JSON'
require 'YAML'
require 'htmlentities'
require 'fastercsv'
$KCODE = 'u'

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

#
# Headword / Lemma structures
#
require 'htmlentities/expanded'
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
# Output hand-crafted YAML
#
# the built-in ruby YAML shits the bed when given a structure of this size, so
# we just pretend we're writing C and printf the thing.
#
#     :head,       :head_orig
#     :lemma,      :lemma_orig
#     :lemmas,     :lemmas_orig
#     :pos,
#     :ll_sign,    :ll_sign,       :ll_sign,
#  x  :freq,       :freq_co,       :freq_im,       :freq_in,       :freq_sp,       :freq_to,       :freq_wr,
#  x  :range,      :range_co,      :range_im,      :range_in,      :range_sp,      :range_to,      :range_wr,
#  x  :disp,       :disp_co,       :disp_im,       :disp_in,       :disp_sp,       :disp_to,       :disp_wr
#  x  :log_lkhd,   :log_lkhd,      :log_lkhd,
# escape as single-quoted string
def esc_sq_str(str) str.to_s.gsub(/'/,"''").gsub(/\\/,"\\\\") end
def pretty_print_word fields, word
  str = fields.map do |f|
    next unless word[f]
    val = case
          when f.to_s =~ /^(log_lkhd|disp).*/   then "%6.2f,"  % (word[f]||0)  # 213613.5
          when f.to_s =~ /^(freq|range).*/      then "%4d,"    % (word[f]||0)
          when f.to_s =~ /^(lemmas).*/          then word[f].to_json+','
          when f.to_s =~ /^(pos).*/             then '%-9s'    % "'#{esc_sq_str(word[f])}',"
          when f.to_s =~ /^(head|lemma|tag).*/  then '%-25s'   % "'#{esc_sq_str(word[f])}',"
          else "'%s'," % esc_sq_str(word[f].to_s)
          end
    str = "#{f}: #{val}"
    # word[f] ? str : str.gsub(/./,' ') # blank out nulls
  end
  str = str.join(' ')
  str.gsub!(/,\s*$/){ $1 }  # json hates terminal commas ,}
  "{ #{str} }"
end
def pretty_print_word_list fields, word_list
  pretty = word_list.map{ |word| pretty_print_word(fields, word)}
  (['']+pretty).join("\n"+(" "*16)+"- ")
end
def dump_words_yaml out_file, fields, words
  out_file   << "- infochimps_dataset:\n"
  out_file   << "    payload:\n"
  out_file   << "      bnc_freq_info:\n"
  _reps = 0
  words.sort_by{|t,i| t.downcase }.each do |tag, info|
    puts info.to_yaml if (!info['head'])
    out_file << "        '#{esc_sq_str(tag)}':\n"
    out_file << "          head:   #{pretty_print_word(     fields,  info['head'])}\n"
    out_file << "          lemmas: #{pretty_print_word_list(fields, info['lemmas'])}\n" if info['lemmas']
    _reps += 1 ; puts "#{Time.now} wrote #{_reps/1000}k out of #{words.length}" if (_reps % 10_000 == 0)
  end
end
def dump_all_yaml out_file_name, fields, words
  File.open(out_file_name, 'w') do |out_file|
    dump_words_yaml out_file, fields, words
    #out_file << words.to_yaml
  end
end

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
# Dump as flat table
#
def dump_table file_out, fields, table
  FasterCSV.open(file_out, "w") do |csv|
    csv << fields
    table.each do |row|
      if row[:lemmas] then
        row = row.dup;
        row[:lemmas]      = row[:lemmas     ].join(LEMMA_SEP)
        row[:lemmas_orig] = row[:lemmas_orig].join(LEMMA_SEP)
      end
      csv << row.values_at(*fields)
    end
  end
end

#
# process files
#
def announce(s) puts "#{Time.now} #{s.to_s}" end
def process_files files_list
  heads      = { }
  lemmas     = { }
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
process_files files_list


# # announce :sorting
# # sorted_words = words.sort_by{ |w,i| [-i['head'][sortby], w] }
# # announce :histogram
# # histogram = { } # build_histogram heads
# #
# # Build a quickie histogram
# #
# def build_histogram heads
#   histogram = { :pos => {}, :range => {}, :disp => {}, :freq => {}, }
#   heads.each do |headword|
#     [:pos, :range, :disp, :freq].each do |field|
#       histogram[field][hist_key(field, headword[field])] ||= 0
#       histogram[field][hist_key(field, headword[field])]  += 1
#     end
#   end
#   histogram
# end
#
# def hist_squash val, pow
#   (val.to_f / pow).round * pow
# end
# def hist_key(field, val)
#   case field
#   when :pos    then val
#   when :range  then val
#   when :disp   then 0.5 * (20*val).round
#   when :freq
#     case
#     when val >= 15_000 then hist_squash(val, 10_000)
#     when val >=  1_500 then hist_squash(val,   1000)
#     when val >=    150 then hist_squash(val,    100)
#     when val >=     15 then hist_squash(val,     10)
#     else val
#     end
#   end
# end



#
# 1_1   0 head PoS lemma  Fr      Ra      Di
# 1_2  10 head PoS        Fr
# 2_1 160 head PoS lemma  FrSp    RaSp    DiSp +- LLSpWr  FrWr  RaWr  DiWr
# 2_2     head PoS        FrSp*                +- LLSpWr  FrWr
# 2_3     head PoS        FrSp                 +- LLSpWr  FrWr*
# 2_4     head PoS        FrSp                 +- LLSpWr* FrWr
# 3_1 120 head PoS lemma  FrCo    RaCo    DiDe +- LLCoTO  FrTO  RaTO  DiCG
# 3_2 120 head PoS        FrCo                 +- LLCoTO  FrTO
# 4_1     head PoS lemma  FrIm    RaIm    DiIm +- LLImIn  FrIn  RaIn  DiIn
# 4_2     head PoS        FrIm                 +- LLImIn  FrIn
#
#
# Word    = Word type (headword followed by any variant forms) - see pp.4-5
# PoS     = Part of speech (grammatical word class - see pp. 12-13)
# Fr      = Rounded frequency per million word tokens (down to a minimum of 10 occurrences of a lemma per million)- see pp. 5
# Ra      = Range: number of sectors of the corpus (out of a maximum of 100) in which the word occurs
# Di      = Dispersion value (Juilland's D) from a minimum of 0.00 to a maximum of 1.00.
#
# FrSp    = Frequency (per million words) in spoken texts of the BNC
# RaSp    = Range across spoken texts (up to a maximum of 10 sectors of the corpus)
# DiSp    = Dispersion in spoken texts: a value from 0 to 1 (Juilland's D)
# LLSpWr  = Log Likelihood score, indicating distinctiveness, or significance of the difference between the spoken and written language frequencies
# FrWr    = Frequency (per million words) in written texts
# RaWr    = Range across written texts (up to a maximum of 90 sectors of the corpus)
# DiWr    = Dispersion in written texts, a value from 0 to 1 (Juilland's D)
#
# FrCo    = Frequency (per million words) in demographically sampled conversational speech
# RaCo    = Range across conversational speech (maximum of 4 sectors)
# DiCo    = Dispersion (Juilland's D) in demographically sampled conversational speech
# LLCoTO  = Distinctiveness, measured in log likelihood (varying from 0.00 to 1.00)
# FrTO    = Frequency (per million words) in context-governed speech (task-oriented)
# RaTO    = Range across task-oriented speech (maximum of 6 sectors)
# DiCG    = Dispersion (Juilland's D) in context-governed speech (task-oriented)
#
# FrIm    = Frequency in imaginative writing
# RaIm    = Range (0-19 for imaginative writing)
# DiIm    = Dispersion (Juilland's D) in imaginative writing
# LLImIn  = Log Likelihood (measure of distinctiveness)
# FrIn    = Frequency in informative writing
# RaIn    = Range (0-71 for informative writing)
# DiIn    = Dispersion (Juilland's D) in informative writing
#
# Ex:
#
#       main|@  PoS     lemma   freq     Range   disp
# ----------------------------------------------------
#       best    Adv     :       81      100     0.96
#       bet     Verb    %       23      96      0.81
#       @       @       bet     21      93      0.79
#       @       @       bets    0       25      0.80
#       @       @       betting 2       72      0.88
#       better  Adv     :       143     100     0.95
#       Betty   NoP     %       14      90      0.62
#       @       @       Betty   13      90      0.62

# %&'()*+,-./0123456789:;<=>@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz
#
# esplanade:~/ics/pool/language/corpora/word_freq_bnc$ time perl -MData::Dumper -e 'use YAML::Syck qw{LoadFile}; $s= LoadFile("word_freq_bnc.yaml");'
#
# real    1m8.978s        user    1m5.965s        sys     0m2.517s        pct     99.27
# esplanade:~/ics/pool/language/corpora/word_freq_bnc$ time ruby -e 'require "YAML"; puts YAML.load(File.open("word_freq_bnc.yaml"))'
#
# list all uncaught entities
# cat ripd/1_1_all_fullalpha.txt | ruby -e 'require "rubygems"; require "htmlentities"; require "YAML"; entity_decoder = HTMLEntities.new;
#   wds={}; STDIN.readlines.map{|l| wd = entity_decoder.decode(l.split("\t")[1]); /(&[^;]+;)/.match(wd).each{|m| wds[m] = 1 }; puts wds.keys.sort.to_yaml'
# list all letters
# cat ripd/1_1_all_fullalpha.txt | ruby -e 'require "rubygems"; require "htmlentities"; require "YAML"; entity_decoder = HTMLEntities.new;
#   wds=""; STDIN.readlines.map{|l| wds += entity_decoder.decode(l.split("\t")[1]) }; ltrs = wds.split(//).uniq.sort; puts ltrs.to_yaml"

# all letters
#
# #$%&'()*+,-./0123456789:;<=> @ABCDEFGHIJKLMNOPQRSTUVWXYZ[\] _ abcdefghijklmnopqrstuvwxyz{|} ÄÅÇÉÑÖÜáàâãåçéèêëíìîïñóòôöõúùûü†°¢£§•¶ß®©™´¨≠ÆØ∞±≤≥¥µ∂∑∏π∫ªºΩæø¬√ƒ≈ÀŒœ‚
#                             ?                              ^ `                             ~
#
# Not Present:
#    'grave'           0x0060    `                  GRAVE ACCENT
#    'quest'           0x003f,   ?                  QUESTION MARK
#                                ^                  (ascii caret)
#                                ~                  (ascii tilde)
#
#

# uncaught (non-SGML) entities:
#
# These are assumed to be mistakes and have been edited by hand in the source
# file: so the the 'corrected' form appears in the '_orig' slot.  All occured as
# a lone headword, at minimal significance (fr 0 / ra 1 / disp 0), and none of
# them appeared elsewhere (in their 'corrected' form as headword entries)
#
# &eacute';      --  &eacute;'
# &eacute/d;     --  &eacute;/d
# &frac23:oz;    --  &frac23;oz
#
# These have no standard SGML-Unicode mappings, and so we have transformed to
# typographically appropriate unicode code points.  The original (SGML-encoded)
# entry persists, of course, in the :head_orig and :lemma_orig slots.
#
# Entity     BNC Description              Repl.Ent.  Hex   Text  Unicode Description of Repl  As it appears in freq. list
# -----------------------------------------------------------------------------------------------------------------------------------------------------
# &bquo;     normalized begin quote mark  &rdquor;    201c “     LEFT DOUBLE QUOTATION MARK   &bquo;             Fore    :       0       1       0.00
# &ft;       feet indicator               &apos;      0027 '     MODIFIER LETTER APOSTROPHE   (85 occurrences)
# &ins;      inches indicator             &quot;      0022 "     QUOTATION MARK               (115 occurrences)
# &rehy;     maps to soft hyphen          &shy;       00ad ­     SOFT HYPHEN                  (3951 occurrences)
# &shilling; British shilling             &sol;       002f /     SOLIDUS                      (11 occurrences)
# &formula;  mathematical formula         &conint;    222e ∮     CONTOUR INTEGRAL             109&formula;km/h   Uncl    :       0       1       0.00
#                                                                                             92&formula;km/h    Uncl    :       0       1       0.00
# &frac17;   fraction one-seventh                          1/7                                &frac17;           Num     :       0       1       0.00
# &frac19;   fraction one-ninth                            1/9                                &frac19;           Num     :       0       1       0.00
# &frac47;   fraction four-sevenths                        4/7                                4&frac47;          Num     :       0       1       0.00
#
# grep '&frac' ./ripd/1_1_all_fullalpha.txt | wc -l  # => 748


#
# Changes to source files:
#
# egrep '^[^ ]' ripd/[234]_?_????*.txt
# ripd/2_4_spokenwritten_ll.txt:        la        Uncl    43      +       1362.7  2
# ripd/3_1_demogvcg_alpha.txt:          fine        Adj     %       186     4       0.92    -       1.3     196     6       0.90
# ripd/3_1_demogvcg_alpha.txt:          int Uncl    :       135     4       0.68    +       760.4   7       6       0.80
# ripd/3_2_demogvcg_ll.txt:             @@     na      Det     19      +       108.0   1       [[?]]
# ripd/4_1_imagvinform_alpha.txt:       basis    NoC     :       14#     19#     0.90    -       4362.7&&        188#    71      0.95
# ripd/4_1_imagvinform_alpha.txt:       @        @       basis   14      19      0.90    -       4362.7  186     7l      0.95
# ripd/4_1_imagvinform_alpha.txt:       @        @       bases   0#      10#     0.75#   -       &&      2       69#     0.87
# ripd/4_2_imagvinform_ll.txt:          lying       Verb    128     +       2399.4  28
# ripd/4_2_imagvinform_ll.txt:          I.  Pron    10      +       410.0   1
# ripd/4_2_imagvinform_ll.txt:          Nato        NoP     2       -       396.2   20
