#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/lib'

require 'hadoop'                       ; include Hadoop
require 'twitter_friends/struct_model' ; include TwitterFriends::StructModel
require 'twitter_friends/rdf_output'

#
# See bundle.sh for running pattern
#

module Rdfify
  class TweetMapper < Hadoop::StructStreamer
    #
    # we need to reorder to
    #   subj pred timestamp pred
    # for correct sorting
    #
    # (this would be unnecessary with Hadoop 1.9 I hear)
    #
    def process thing
      thing.to_rdf3_tuples.each do |subj, obj, pred, timestamp|
        puts [subj, obj, timestamp, pred].join("\t")
      end
    end

    #
    # Skip bogus records
    #
    def itemize line
      return if line =~ /^(?:bogus|bad_record)/
      super line
    end
  end

  #
  # We'd like to extract the *latest* value for each property
  #
  #
  # Mapper emits
  #  subject    predicate       timestamp       object
  #
  # We sort on the first three fields, guaranteeing that the last value for a
  # given subject+predicate is the latest seen.  Discarding all but the last
  # uniqifies immutable properties and gives the most up-to-date for mutable
  # properties
  #
  # Note especially that the scraped_at value thus holds the 'last time seen'
  # for the **subject** (and not for the subject-predicate).  For example, our
  # last scrape might have yielded a TwitterUserPartial giving a new
  # followers_count, while the statuses_count came from an earlier TwitterUser
  # sighting.  The scraped_at value gives only the latest (partial user) date.
  #
  # Relationships are mutable, but for technical issues we can't count on seeing
  # them disappear.
  #
  class UnifyByLatestReducer < AccumulatingStreamer
    attr_accessor :final_value

    #
    # Key on subject + predicate
    #
    def get_key vals
      vals[0..1]
    end

    #
    # Just adopt each value in turn: the last one's the one you want.
    #
    def accumulate *vals
      self.final_value = *vals
    end
    #
    def reset!
      self.final_value = nil
    end
    #
    # Emit the last-seen (latest) value
    #
    def finalize
      subj, obj, timestamp, pred = final_value
      puts TwitterRdf.rdf_triple(subj, obj, pred, timestamp)
    end
  end
end

class RdfifyScript < Hadoop::Script
end
RdfifyScript.new(Rdfify::TweetMapper, Rdfify::UnifyByLatestReducer).run
