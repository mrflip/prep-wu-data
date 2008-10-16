#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$KCODE='u'
require 'iconv'
require 'rubygems'
require 'imw'; include IMW;
require 'imw/extract/html_parser'
require 'dm-core'
require 'json'; require 'fastercsv'
$: << File.dirname(__FILE__)+'/..'

as_dset __FILE__

#
# Files collected with
#   wget -r -l1 -nv -erobots=off --no-clobber 'http://www.rockband.com/music/getSearchResultsTable_Ajax?sort_on=songs.NAME&sort_order=asc'
#

#
# Song URLs
#
MAINLIST_URL = 'www.rockband.com/music/getSearchResultsTable_Ajax?sort_on=songs.NAME&sort_order=asc'
def song_urls
  song_urls_doc = Hpricot(File.open(path_to(:ripd, MAINLIST_URL)))
  (song_urls_doc/'div#content//tr/td.song/a').map{|song| song.attributes['href']}
end

#
# Basic Song HTML Structure
#
els = HTMLParser.new({
      '//div#content/div/div.middle' => {
        'h1'                                      => :full_title ,
        'h1/em'                                   => :band ,
      { 'div.page-sidebar/img.albumart' => :src } => :coverart_url,
      { 'div.page-sidebar/img.albumart' => :alt } => :title,
      'div.page-sidebar/p.questionnaire'          => [:ratings],
      'div.songinfo/p.questionnaire'              => [:songinfo],
      'div.songinfo/h2/span'                      => [:description_heads],
      'div.songinfo/div.overview'                 => [:descriptions],
    }
    })

#
# Neaten Song Info
#
class RBSong < Struct.new("RBSongStruct",
    :band, :title,
    :album, :release_year, :genre, :type, :rockband_release,
    :rating_guitar, :rating_vocals, :rating_drums, :rating_bass, :rating_band,
    :song_url,
    :description_story, :description_trivia, :description_gameplayhints, :description_wherearetheynow,
    :coverart_url
    )
  def initialize(song_url, raw)
    self.song_url = song_url
    raw = raw.to_a[0][1][0]
    self.band     = raw[:band].gsub(/^by /,'')
    [:title, :coverart_url].each do |attr|
      self[attr] = raw[attr]
    end
    extract_songinfo(raw[:songinfo])
    extract_ratings(raw[:ratings])
    extract_descriptions(raw[:description_heads], raw[:descriptions])
  end

  #
  # extract the sequential album/genre/release/type/rb_release
  #
  def extract_songinfo(songinfo)
    attr_map = {
      'Album' => :album, 'Release Year' => :release_year,
      'Genre' => :genre, 'Type' => :type, 'Released' => :rockband_release,
    }
    songinfo.each do |info|
      attr, val = %r{\s*(.*)<br ?/>\s*<span><strong>(.*)</strong></span>}.match(info).captures
      self[attr_map[attr]] = val
    end
  end

  #
  # extract the ratings
  #
  def extract_ratings(ratings)
    rating_map = Hash.zip(%w[zero one two three four five devils], (0..6).to_a)
    ratings.each do |info|
      attr, val = %r{\s*(.*)<br ?/>\s*<span class="dots-([^\"]+)"}.match(info).captures
      attr = ("rating_"+attr.downcase).to_sym
      self[attr] = rating_map[val]
    end
  end

  #
  # Just trust the descriptions are in a common order
  #
  def extract_descriptions(description_heads, descriptions)
    attr_map = {
      'The Story' => :description_story,   'Gameplay Hints'      => :description_gameplayhints,
      'Trivia'    => :description_trivia,  'Where Are They Now?' => :description_wherearetheynow,
    }
    description_heads.zip(descriptions).each do |attr, val|
      next if (attr =~ /More info about this song coming soon/i)
      if ! attr_map[attr] then puts "No attr for #{attr}"; next   end
      self[attr_map[attr]] = val.strip
    end
  end
end

#
# Scrape
#
songs = []
song_urls[0..-1].each do |song_url|
  song_file = path_to(:ripd, "www.rockband.com", song_url)
  parsed = els.parse_file(song_file)
  songs << RBSong.new(song_url, parsed)
end

FasterCSV.open(path_to(:fixd, 'rockband_songs.csv'), 'w') do |csv_file|
  csv_file << RBSong.members
  songs.each do |song|
    csv_file << song.to_a
  end
end
YAML.dump(songs.map(&:to_hash), File.open(path_to(:fixd, 'rockband_songs.yaml'), 'w'))
