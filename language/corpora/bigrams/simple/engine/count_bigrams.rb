#!/usr/bin/env ruby
require 'wukong/script'

Settings.log_interval = 100_000

Settings.define :min_length, :default => 5,  :description => "Minimum length of funny words to return", :type => Integer
Settings.define :max_length, :default => 10, :description => "Maximum length of funny words to return", :type => Integer
Settings.define :num_words,  :default => 10, :description => "Number of funny words to return", :type => Integer

# UNACCEPTABLE_CHARS = /[^a-zA-Z]/ # words and acronyms
UNACCEPTABLE_CHARS = /[^a-z]/

class Mapper < Wukong::Streamer::RecordStreamer
  def process word
    return if word =~ UNACCEPTABLE_CHARS
    word = "^#{word}$"
    word.chars.to_a[0..-2].zip(word.chars.to_a[1..-1]).each{|c1,c2| yield [c1,c2] }
  end
end

class CountPivoter < Wukong::Streamer::RecordStreamer
  def before_stream
    @unigram_counts = Hash.new{|c1_hsh,c1| c1_hsh[c1] = 0 }
    @bigram_counts  = Hash.new{|c1_hsh,c1| c1_hsh[c1] = Hash.new{|c2_hsh,c2| c2_hsh[c2] = 0 } }
    @total_chars    = 0
  end

  def process c1, c2, count
    return if (c1 != '^' && c2 =~ /[A-Z]/) # don't use interior capital letters
    count = count.to_f
    @unigram_counts[c1]    += count.to_f
    @bigram_counts[c1][c2]  = count
    @total_chars           += count.to_f
  end

  def after_stream
    puts PREAMBLE
    dump_unigram_cumulative_freq
    dump_bigram_cumulative_freq
    puts POSTAMBLE
  end

  def random_from_cdf cdf
    offset = rand
    cdf.find{|c, freq| offset < freq}.first
  end

  def funny_word
    char = random_from_cdf(bigram_cdf_hsh['^'])
    word = [char]
    (3 * Settings.max_length).times do
      cdf = bigram_cdf_hsh[char]
      char = random_from_cdf(cdf);
      break if char == '$'
      word << char
    end
    word.join
  end

  def try_funny_word min_length, max_length
    word = ''
    100.times do
      word = funny_word
      return word if word.length >= min_length && word.length <= max_length
    end
    word
  end

  def sorted_cdf arr, base_count
    cumulative_freq = 0
    cdf = arr.sort_by{|char, ct| -ct }.map do |char, ct|
      freq = ct.to_f / base_count.to_f
      cumulative_freq += freq
      [char, cumulative_freq]
    end
    warn "hmm... cumulative_freq [#{cumulative_freq}] wasn't 1.0" unless (1.0 - cumulative_freq < 1e-6)
    cdf
  end

  def unigram_cdf
    @unigram_cdf ||= sorted_cdf(@unigram_counts, @total_chars)
  end

  def bigram_cdf_hsh
    return @bigram_cdf_hsh if @bigram_cdf_hsh
    @bigram_cdf_hsh = {}
    @bigram_counts.each do |c1, c2_counts|
      @bigram_cdf_hsh[c1] = sorted_cdf(c2_counts, @unigram_counts[c1])
    end
    @bigram_cdf_hsh
  end

  def dump_unigram_cumulative_freq
    puts "  UNIGRAM_CDF = ["
    unigram_cdf.each do |k, v|
      puts "    [%12.10f, \"%s\"]," % [v, k]
    end
    puts "  ] # UNIGRAM_CDF\n\n"
  end

  def dump_bigram_cumulative_freq
    puts "  BIGRAM_CDF_HSH = {"
    # hsh = bigram_cdf_hsh.dup
    # arr = [['^', hsh.delete('^')]] + hsh.sort
    bigram_cdf_hsh.each do |c1, c1_cdf|
      print "    '#{c1}' => ["
      c1_cdf.each{|k, v| print " [%12.10f, \"%s\"]," % [v, k] }
      puts "  ],"
    end
    puts "  } # BIGRAM_CDF_HSH\n\n"
  end

  PREAMBLE = %Q{#!/usr/bin/env ruby\n\nclass ReadableRandomString\n}

  POSTAMBLE = <<EOF

  class << self

  def random_from_cdf cdf
    offset = rand
    cdf.find{|c, freq| offset < freq}.first
  end

  def funny_word
    char = random_from_cdf(BIGRAM_CDF_HSH['^'])
    word = [char]
    (3 * Settings.max_length).times do
      cdf = bigram_cdf_hsh[char]
      char = random_from_cdf(cdf);
      break if char == '$'
      word << char
    end
    word.join
  end

  def try_funny_word min_length, max_length
    word = ''
    100.times do
      word = funny_word
      return word if word.length >= min_length && word.length <= max_length
    end
    word
  end

  end
end

8.times{ puts ReadableRandomString.funny_word }
EOF

end

Wukong.run(Mapper, CountPivoter)
