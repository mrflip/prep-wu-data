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
      return [] unless t
      t = t.downcase;
      # kill off all punctuation except 's
      # this includes hyphens (words are split)
      t = t.gsub(/[^\w\']+/, ' ').gsub(/\'s\b/, '!').gsub(/\'/, ' ').gsub(/!/, "'s")
      # Busticate at whitespace
      words = t.strip.split(/\s+/)
      words.reject!{|w| w.blank? || (w.length < 3) }
      words
    end


    #
    # remove elements specific to tweets
    #
    def tokenize_tweet_text t
      # skip default message from early days
      return [] if (! t) || (t =~ /just setting up my twttr/);
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
      # emit tokens
      words.each do |word|
        puts Token.new(:tweet, tweet.twitter_user_id, word).output_form
      end
    end

    def gen_profile_tokens user_profile
      desc = user_profile.decoded_description
      tokenize(desc).each do |word|
        puts Token.new(:desc, user_profile.id, word).output_form
      end
      name = user_profile.decoded_name
      tokenize(name).each do |word|
        puts Token.new(:name, user_profile.id, word).output_form
      end
      loc = user_profile.decoded_location
      tokenize(loc).each do |word|
        puts Token.new(:loc,  user_profile.id, word).output_form
      end
    end

    #
    #
    #
    def process thing
      case thing
      when Tweet                then gen_tweet_tokens(thing)
      when TwitterUserProfile   then gen_profile_tokens(thing)
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
      "%010d"%freq
    end

    def stream
      %x{/usr/bin/uniq -c}.split("\n").each do |line|
        freq, rest = line.chomp.strip.split(/\s+/, 2)
        freq = freq.to_i
        # next if freq <= 1
        puts [rest, freq_key(freq)].join("\t")
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
