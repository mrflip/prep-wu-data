#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'wukong'                       ; include Wukong
require 'wuclan/twitter'               ; include Wuclan::Twitter

class TweetBagMapper < Wukong::Streamer::RecordStreamer

  def process *args
    text = (args[10] || return)
    return unless regexp.match(text || '')
    yield args
  end

  def regexp
    /(LADY.*GAGA)/i
  end

end

Wukong::Script.new(TweetBagMapper, nil).run
