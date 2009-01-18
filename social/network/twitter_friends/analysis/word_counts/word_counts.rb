#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../../lib'

require 'hadoop'                       ; include Hadoop
require 'twitter_friends/struct_model' ; include TwitterFriends::StructModel
require 'twitter_friends/grok'         ; include TwitterFriends::Grok::TweetRegexes
require 'twitter_friends/words'

#
# See bundle.sh for running pattern
#

module WordFreq
  class Mapper < Hadoop::StructStreamer

    #
    # This is pretty simpleminded.
    #
    # Would be much better to use NLTK. But here we are.
    #
    def tokenize t
      # kill off all punctuation except 's
      # this includes hyphens (words are split)
      t = t.gsub(/[^\w\']+/, ' ').gsub(/\'s\b/, '!').gsub(/\'/, ' ').gsub(/!/, "'s")
      # Busticate at whitespace
      words = t.strip.split(/\s+/)
    end


    #
    # remove elements specific to tweets
    #
    def tokenize_tweet_text t
      # skip default message from early days
      return [] if t =~ /just setting up my twttr/;
      # downcase
      t = t.downcase;
      # Remove semantic non-words, except hashtags: we like those.
      t = t.gsub(RE_URL, ' ')           # urls
      t = t.gsub(RE_RETWEET, ' ')       # atsigns with a re-tweet part
      t = t.gsub(RE_RTWHORE, ' ')       # atsigns with a retweet whore
      t = t.gsub(RE_ATSIGNS, ' ')       # all atsigns
      # Tokenize the remainder
      tokenize t
    end

    def gen_tweet_tokens tweet
      # simpleminded test for non-latin script: don't bother if > 20 entities
      return [] if tweet.text.count('&') > 20
      # Tokenize
      words = tokenize_tweet_text tweet.decoded_text
      words.reject!{|w| w.blank? || (w.length < 4) }
      # emit tokens
      words.each do |word|
        puts Token.new(:tweet, :all, word).output_form
      end
    end

    #
    #
    #
    def process thing
      case thing
      when Tweet        then gen_tweet_tokens(thing)
      end
    end
  end

  class Reducer < Hadoop::Streamer
    #
    #
    def sorting_by_freq_key freq
      logkey    = ( 10*Math.log10(freq) ).floor
      sort_log  = [1_000          -logkey,  1].max
      sort_freq = [1_000_000_000 - freq,    1].max
      "%03d\t%010d" % [sort_log, sort_freq]
    end

    def freq_key freq
      "% 10d"%freq
    end

    def stream
      %x{/usr/bin/uniq -c}.split("\n").each do |line|
        freq, origin, owner, word = line.chomp.strip.split(/\s+/)
        freq = freq.to_i
        # next if freq <= 1
        puts [word, origin, owner, word, freq_key(freq)].join("\t")
      end
    end
  end


  #
  # uniq -c to count occurrences
  #
  class Script < Hadoop::Script
  end
end

#
# Executes the script
#
WordFreq::Script.new(
  WordFreq::Mapper,
  WordFreq::Reducer
  ).run
