#! /usr/bin/env ruby

require 'rubygems'
require 'wukong'

class Mapper < Wukong::Streamer::RecordStreamer

  def recordize line
    line.strip!
    line.gsub!(%r{^<http://dbpedia.org/resource/([^>]+)> <[^>]+> \"}, '') ; title = $1
    line.gsub!(%r{\"@en \.},'')
    [ title, line ]
  end

  def process title, line
    yield [ title, line ]
  end

end

Wukong::Script.new(Mapper, nil).run
