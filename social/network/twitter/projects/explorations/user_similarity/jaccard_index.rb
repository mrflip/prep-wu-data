#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'wukong/and_pig'
require 'set'

class TermsetStreamer < Wukong::Streamer::RecordStreamer
  def process user_a_id, user_b_id, user_a_termset, user_b_termset, *_
    yield [user_a_id, user_b_id, jaccard_index(bag_to_set(user_a_termset), bag_to_set(user_b_termset))]
  end

  def bag_to_set termbag
    termbag.from_pig_bag.to_set
  end

  #
  # Returns jaccard similarity index between two objects
  #
  def jaccard_index(x, y)
    x.intersection(y).size.to_f / x.union(y).size.to_f
  end

end

Wukong::Script.new(TermsetStreamer, nil).run
