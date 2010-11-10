#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'

module ReIndex
  class Mapper < Wukong::Streamer::RecordStreamer
    def recordize str
      words = str.split(",")
      words
    end
    def process country, autosys_name, provider, type, score, *_
      yield [ country, autosys_name, provider, type, score ]
    end
  end

  class Reducer < Wukong::Streamer::AccumulatingReducer
    attr_accessor :aggregate_scores
    def get_key *record
      record[0..2]
    end
    def start! *record
      self.aggregate_scores = [ "", "", "", "" ]
    end

    def accumulate country, autosys_name, provider, type, score
      if type == "Availability"
        self.aggregate_scores[0] = score
      end
      if type == "Connect Time"
        self.aggregate_scores[1] = score
      end
      if type == "Response Time"
        self.aggregate_scores[2] = score
      end
      if type == "Throughput"
        self.aggregate_scores[3] = score
      end
    end
    def finalize
      yield [key, aggregate_scores].flatten
    end
  end
end

Wukong::Script.new(
  ReIndex::Mapper,
  ReIndex::Reducer,
  :sort_fields => 3,
  :partition_fields => 3
).run


