#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'wukong'                       ; include Wukong
require 'wuclan/twitter'               ; include Wuclan::Twitter::Model
require 'wukong/encoding'


class GrepMapper < Wukong::Streamer::StructStreamer

  # Keywords: Sigur Ros, Sigur Rós, Jónsi, Jonsi, iamjonsi, TheNewPornos, Neko Case, Destroyer, New Pornographers
  # keywords = "Sigur Ros, Sigur Rós, Jónsi, Jonsi, iamjonsi, TheNewPornos, Neko Case, Destroyer, New Pornographers"

  KEYWORDS = %r{\b(sigur\sros|sigur\sr[^s\s]+s|j[^n\s]+nsi|jonsi|iamjonsi|thenewpornos|neko\scase|destroyer|new\spornographers)}

  def process tweet, *_, &block
    return unless tweet.text =~ KEYWORDS
    keys = tweet.text.downcase.scan(KEYWORDS).flatten.uniq.join(",")
    yield [tweet.to_flat, keys]
  end

end

# Execute the script
Wukong::Script.new(
  GrepMapper,
  nil
  ).run
