#!/usr/bin/env ruby
require 'imw' ; include IMW
require 'wordcloud_models'
require 'fastercsv'
as_dset(__FILE__)

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup_remote_connection IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_politics_campaignus2008_wordclouds' })
WordFreq.auto_upgrade!
WordUsage.auto_upgrade!
Event.auto_upgrade!
Speaker.auto_upgrade!

class Normalizer
  NOTATIONS = {
    /--/                   => "##PAUSE##",
    /\(sic\)/              => "##SIC##",
    /\[mispronunciation\]/ => '##MISPRONUNCIATION##',
    /\.\.\./               => ' ##PAUSE## ',
  }
  REVERSIBLE_PHRASES = {
    "wall street" => "wall~street", "main street" => "main~street", "my friends" => "my~friends",
    "middle class" => "middle~class",
    "fannie mae"  => "fannie~mae",  "freddie mac" => "freddie~mac",
  }
  PUNCTUATED = [
    /a\.m\./, /p\.m\./, /No\. /, /U\.S\./, /U\.S\.A\./, /D\.C\./,
    /\$?\d+\.\d/,
    /\$?\d+,\d/,
  ]
  PUNC = ',\\?\\.";'
  # COLLAPSIBLE_PHRASES = {
  #   "obama's" => "obama", "mccain's" => 'mccain',
  #   "putin's" => 'putin', "bush's" => 'bush',
  #   "off-shore" => "offshore",
  # }

  def self.normalize raw
    NOTATIONS.each{|raw_notation, notation| raw.gsub!(raw_notation, notation) }
    REVERSIBLE_PHRASES.each{|phrase, repl|  raw.gsub!(/#{phrase}/, repl) }
    PUNCTUATED.each{|phrase|  raw.gsub!(phrase){|ph| ph.gsub(/([#{PUNC}])/){|l| '\\'+l}} }
    raw.gsub!(/\$(\d+)\s*(million|billion|thousand)/, '\1~\2')

    # break off punctuation
    raw.gsub!(/([#{PUNC}])/, ' \1 ')
    raw.gsub!(/\\ ([#{PUNC}]) /, '\1')
    norm = raw.downcase
    puts raw
    norm_words = norm.split(/\s+/)
    raw_words  = raw.split( /\s+/)
    REVERSIBLE_PHRASES.each{|phrase, repl| raw_words.each{|w| w.gsub!(/#{repl}/, phrase); w.gsub!(/~/, ' ') } }
    raise "word lists don't match" unless norm_words.length == raw_words.length
    [raw_words, norm_words]
  end
end

class DebateAnalyzer
  attr_accessor :trnames_speakers
  def initialize(trnames_speakers)
    self.trnames_speakers = trnames_speakers
  end
  def trnames()  trnames_speakers.keys   end
  def speakers() trnames_speakers.values end

  #
  # Get lines for each speaker
  #
  def split_raw_by_speaker raw_file_name
    # Split by speaker
    lines = File.open("rawd/#{raw_file_name}-raw.txt").read.split(/\n(#{trnames.join('|')}): /)[1..-1]
    # Break out each speaker's lines
    spkr_lines = { } ; speakers.each{|spkr| spkr_lines[spkr] = [] }
    lines.in_groups_of(2){|trname,text| spkr_lines[trnames_speakers[trname.chomp]] << text }
    spkr_lines
  end

  def dump_file_name(event)
    path_to(:fixd, "%s.csv"%[event.name.underscore])
  end

  def record_words event, spkr_lines
    FasterCSV.open(dump_file_name(event), "w") do |dump_file|
      spkr_lines.each do |speaker, lines|
        word_order = 0
        lines.each_with_index do |line, para|
          raw_words, norm_words = Normalizer.normalize line
          raw_words.each_with_index do |raw_word, i|
            dump_file << [speaker.id, event.id, raw_word, norm_words[i], para, word_order]
            word_order += 1
          end
        end
      end
    end
  end

  def bulk_load(event, table, fields)
    fields_str = fields.map{|f| "`#{f}`"}.join(', ')
    loader_query = %Q{
        LOAD DATA INFILE "#{dump_file_name(event)}"
          IGNORE INTO TABLE `#{table}`
          FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
          (#{fields_str})
    }
    repository(:default).adapter.execute(loader_query)
  end

end

trnames_speakers = {
  'LEHRER' => Speaker.find_or_create(:name => 'Jim Lehrer'),
  'OBAMA'  => Speaker.find_or_create(:name => 'Barack Obama'),
  'MCCAIN' => Speaker.find_or_create(:name => 'John McCain'),
}
event = Event.find_or_create(:name => 'First Presidential Candidate Debate',
    :date => '2008-09-26', :site => 'University of Mississippi', :city => 'Oxford', :state => 'MS', :country => 'us')
da = DebateAnalyzer.new(trnames_speakers)
spkr_lines = da.split_raw_by_speaker("words_debate_20080926")
spkr_words = da.record_words event, spkr_lines
da.bulk_load(event,'word_usages', %w[speaker_id event_id raw_word norm_word para word_order])

