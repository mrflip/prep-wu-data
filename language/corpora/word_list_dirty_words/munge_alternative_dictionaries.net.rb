#!/usr/bin/env ruby
# -*- coding: mule-utf-8 -*-
require 'iconv'
# require "encoding/character/utf-8"
require 'rubygems'
require 'hpricot'
require 'oniguruma'
require 'JSON'
require 'YAML'
require 'UniversalDetector'
$KCODE = 'UTF8'
require 'ya2yaml'
include Oniguruma


# Files screenscraped from http://www.alternative-dictionaries.net/dictionary
ALT_DICT_DIR = File.expand_path("~/ics/ripd/www.alternative-dictionaries.net/dictionary")
# Schema input
SCHEMA_FILE = "./alternative_dictionaries_multilingual_indecent_word_list.icss.yaml"
schema = YAML.load(File.open(SCHEMA_FILE))
# Output
OUT_DIR = File.expand_path("~/ics/pool/language/corpora/word_list_dirty_words")

#
# why are you such a pain, unicode?
#
def ogsub(str, re, sub)
  ORegexp.new(re, :encoding => ENCODING_UTF8).gsub(str,  sub)
end

#
#
#
alt_dict_site_url = "http://www.alternative-dictionaries.net/dictionary"
filth = []
Dir[File.join(ALT_DICT_DIR, "*", "index.html")].each do |fn|
  # open the file
  unfucked_text = Iconv.new('utf-8', 'utf-8').iconv(File.open(fn).readlines.join("\n"))
  doc = Hpricot(unfucked_text)
  # extract info
  lang = File.basename(File.dirname(fn))
  (doc/"table.entryIndex/tr/td/a").each do |anchor|
    link = File.join(alt_dict_site_url, lang, anchor["href"])
    text = anchor.inner_html
    smushed = ogsub(text,    '\\([^\\)]+\\)\s*$', '').downcase  # parentheticals
    smushed = ogsub(smushed, ',.*$',              '')          # foo, the
    smushed = ogsub(smushed, '[^\w\s]+',          '')          # non-letter/non-space
    stem    = ogsub(smushed, '[^[:alnum:]]',      '')          # all non-letters
    filth.push({ 'word' => smushed, 'phrase' => text, 'stem' => stem, 'definition_url' => link, 'lang' => lang })
  end
end


out_schema = schema.dup
out_schema['infochimps_dataset']['payload'] = [ { 'word_list' => filth } ]
# puts out_schema.ya2yaml
out_file = File.join(OUT_DIR, "alternative_dictionaries_multilingual_indecent_word_list.yaml")
File.open(out_file, "w") do |f|
  f << (out_schema.ya2yaml)   # ya2yaml for utf-8 support in 1.8
end

out_schema = schema.dup
out_schema['infochimps_dataset']['payload'] = [ { 'word_list' => filth.reject{ |w| w['lang'] !~ /english/i } }]
out_file = File.join(OUT_DIR, "alternative_dictionaries_english_indecent_word_list.yaml")
puts out_file
File.open(out_file, "w") do |f|
  f << (out_schema.ya2yaml)   # ya2yaml for utf-8 support in 1.8
end
