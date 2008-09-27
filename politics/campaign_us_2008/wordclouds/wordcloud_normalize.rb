#!/usr/bin/env ruby
require 'imw/utils'
class Array #:nodoc:
  def in_groups_of(number, fill_with = nil, &block)
    require 'enumerator'
    collection = dup
    collection << fill_with until collection.size.modulo(number).zero?
    collection.each_slice(number, &block)
  end
end

class DebateAnalyzer
  attr_accessor :topic
  def initialize(topic)
    self.topic = topic
  end

  def dump_file step, group
    File.open("#{topic}-#{step}-#{group.downcase}.txt", 'w')
  end

  #
  # Get lines for each speaker
  #
  def split_raw_by_speaker
    # Split by speaker
    lines = File.open("rawd/#{topic}-raw.txt").read.split(/\n(OBAMA|LEHRER|MCCAIN): /)[1..-1]
    # Dump each speaker's liknes
    spkr_lines = { 'LEHRER' => [], 'OBAMA' => [], 'MCCAIN' => [], }
    lines.in_groups_of(2){|spkr,text| spkr_lines[spkr] << text }
    spkr_lines.each do |group,texts| dump_file("lines", group) << texts ; end
    spkr_lines
  end


  def depunctuate texts
    reversible_phrases = {
      "wall street" => "wall_street", "main street" => "main_street", "my friends" => "my_friends",
      "middle class" => "middle_class",
      "fannie mae"  => "fannie_mae",  "freddie mac" => "freddie_mac",
      "a\\.m\\." => 'am', 'p\\.m\\.' => 'pm',
    }
    collapsible_phrases = {
      "obama's" => "obama", "mccain's" => 'mccain',
      "putin's" => 'putin', "bush's" => 'bush',
      "off-shore" => "offshore", "\\(sic\\)" => " ", "\\[mispronunciation\\]" => ' ',
    }
    words = texts.join(" ")
    words.downcase!
    words.gsub!(/ -- /, " ")
    reversible_phrases.each{ |phrase, repl| words.gsub!(/#{phrase}/, repl) }
    collapsible_phrases.each{|phrase, repl| words.gsub!(/#{phrase}/, repl) }
    words.gsub!(/(\d+),(\d)/, '\1\2')
    words.gsub!(/\$(\d+)\s*(million|billion|thousand)/, '\1_\2')
    words.gsub!(/[\s,?.\";]+/, " ")
    word_list = words.split(/\s/)
    word_list.map!{|w| reversible_phrases.each{|phrase, repl| w.gsub!(/#{phrase}/, repl) }; w }
    word_list
  end
  def word_lists spkr_lines
    spkr_words = {}
    spkr_lines.each{|spkr, texts| spkr_words[spkr] = depunctuate(texts)}
    spkr_words.each do |group,words| dump_file("words", group) << words.join(" "); end
    spkr_words
  end

  def histogram words
    hist = { }
    words.each{|w| hist[w]||=0; hist[w] += 1 }
    hist
  end
  def histograms spkr_words
    spkr_hists = {}
    spkr_words.each{|spkr, words| spkr_hists[spkr] = histogram(words) }
    total_words = {}
    spkr_words.each{|spkr, words| total_words[spkr] = words.length }
    spkr_hists.each do |spkr,hist| dump_file("hists", spkr) << [
        "\n** #{spkr} ** #{total_words[spkr]} words\n\n",
        hist.sort_by{|w,n| -n}.map{|w,n| "%6d\t%7.3f\t%s\n"%[n, (1000.0*n)/total_words[spkr], w] }
      ].flatten
    end
    spkr_hists
  end

end

da = DebateAnalyzer.new "words_debate_20080926"
spkr_lines = da.split_raw_by_speaker
spkr_words = da.word_lists spkr_lines
spkr_hists = da.histograms spkr_words
