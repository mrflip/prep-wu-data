#!/usr/bin/env ruby
require 'imw'
require 'wordcloud_models'

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup_remote_connection IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_language_corpora_word_freq' })
WordFreq.auto_upgrade!
WordUsage.auto_upgrade!
Event.auto_upgrade!
Speaker.auto_upgrade!

class DebateAnalyzer
  attr_accessor :topic, :trnames_speakers
  def initialize(topic, trnames, trnames_speakers)
    self.topic    = topic
    self.trnames_speakers = trnames_speakers
  end
  def trnames()  trnames_speakers.keys   end
  def speakers() trnames_speakers.values end

  #
  # Get lines for each speaker
  #
  def split_raw_by_speaker
    # Split by speaker
    lines = File.open("rawd/#{topic}-raw.txt").read.split(/\n(#{trnames.join('|')}): /)[1..-1]
    # Break out each speaker's lines
    spkr_lines = { } ; speakers.each{|spkr| spkr_lines[spkr] = [] }
    lines.in_groups_of(2){|spkr,text| spkr_lines[trnames_speakers[spkr]] << text }
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
    spkr_words = []
    spkr_lines.each{|spkr, texts| spkr_words[spkr] = depunctuate(texts) }
    spkr_words.each_with_index do
      WordUsage.make(speaker, event, word, order)
    end
  end

  # def histogram words
  #   hist = { }
  #   words.each{|w| hist[w]||=0; hist[w] += 1 }
  #   hist
  # end
  # def histograms spkr_words
  #   spkr_hists = {}
  #   spkr_words.each{|spkr, words| spkr_hists[spkr] = histogram(words) }
  #   total_words = {}
  #   spkr_words.each{|spkr, words| total_words[spkr] = words.length }
  #   spkr_hists
  # end

end

trnames_speakers = {
  'LEHRER' => Speaker.find_or_create(:name => 'Jim Lehrer'),
  'OBAMA'  => Speaker.find_or_create(:name => 'Barack Obama'),
  'MCCAIN' => Speaker.find_or_create(:name => 'John McCain'),
}
event = Events.find_or_create(:name => 'First Presidential Candidate Debate',
    :date => '2008-09-26', :site => 'University of Mississippi', :city => 'Oxford', :state => 'MS', :country => 'us')
da = DebateAnalyzer.new("words_debate_20080926", trnames_speakers)
# spkr_lines = da.split_raw_by_speaker
# spkr_words = da.word_lists spkr_lines,

