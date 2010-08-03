#!/usr/bin/env ruby

$: << File.dirname(__FILE__)

require 'rubygems'
require 'wukong'
require 'trstrank_table'
require 'atrank_table'

Settings.define :rank_type,   :default => "a_follows_b", :type => String, :description => 'Type of binning to use'

Float.class_eval do def round_to(x) ((10**x)*self).round end ; end

# FIXME: dont check options every f*ing iteration
class Mapper < Wukong::Streamer::RecordStreamer
  def process *args
    return unless args.length == 3
    uid, followers, scaled = args
    rank = (scaled.to_f*10.0).round.to_f/10.0
    case options.rank_type
    when "a_follows_b" then
      bin  = TRSTRANK_TABLE["#{logbin(followers)}"]
    when "a_atsigns_b" then
      bin = ATRANK_TABLE["#{logbin(followers)}"]
    end
    return if bin.blank?
    tq = bin[rank].round
    yield [uid, scaled, tq]
  end

  def logbin(x)
    begin
      Math.log10(x.to_f).round_to(1)
    rescue Errno::ERANGE
      return 0.01
    end
  end

end

Wukong::Script.new(Mapper, nil).run
