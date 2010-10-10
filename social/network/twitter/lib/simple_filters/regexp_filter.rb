#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'wukong'                       ; include Wukong
require 'wuclan/twitter'               ; include Wuclan::Twitter

# field 10 is tweet text, field 11 is tweet source
SEARCH_FIELD  = 10
SEARCH_REGEXP = /(@skimble|cyclemeter)/i

class TweetBagMapper < Wukong::Streamer::RecordStreamer

  def process *args
    field = (args[SEARCH_FIELD] || return)
    return unless SEARCH_REGEXP.match(field || '')
    yield args
  end

end

Wukong::Script.new(TweetBagMapper, nil).run
