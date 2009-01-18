#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../../lib'

require 'hadoop'                       ; include Hadoop
require 'twitter_friends/struct_model' ; include TwitterFriends::StructModel
require 'twitter_friends/grok'         ; include TwitterFriends::Grok::TweetRegexes

#
# See bundle.sh for running pattern
#

module WordCount
  class Mapper < Hadoop::StructStreamer
    #
    # we need to reorder to
    #   subj pred timestamp pred
    # for correct sorting
    #
    # (this would be unnecessary with Hadoop 1.9 I hear)
    #
    def process thing
      return unless thing.is_a?(Tweet)
      return if thing.text =~ /just setting up my twttr/;
      # simpleminded test for non-latin script: don't bother if > 20 entities
      return if thing.text.count('&') > 20
      # Remove semantic non-words
      t = thing.decoded_text.downcase;
      t = t.gsub(RE_URL, ' ')           # urls
      t = t.gsub(RE_RETWEET, ' ')       # atsigns with a re-tweet part
      t = t.gsub(RE_RTWHORE, ' ')       # atsigns with a retweet whore
      t = t.gsub(RE_ATSIGNS, ' ')       # all atsigns
      # we like hashtags; leave those in
      # kill off all punctuation except 's
      # this includes hyphens (words are split)
      t = t.gsub(/[^\w\']+/, ' ').gsub(/\'s\b/, '!').gsub(/\'/, ' ').gsub(/!/, "'s")
      words = t.strip.split(/\s+/)
      words.reject!{|w| w.blank? || (w.length < 4) }
      puts words.join("\n") unless words.blank?
    end
  end

  #
  # uniq -c to count occurrences
  #
  class Script < Hadoop::Script
    def reduce_command
      '/usr/bin/uniq -c'
    end
  end
end

#
# Executes the script
#
WordCount::Script.new(
  WordCount::Mapper,
  nil
  ).run
