#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'wukong'
require 'wukong/encoding'
require 'set'
require 'wuclan/twitter'               ; include Wuclan::Twitter
require 'wuclan/twitter/token'
require 'wuclan/twitter/token/tweet_url'

#
# Not full list of stopwords here, just those > 2 characters
#
STOPWORDS = %w[
about above across after again against all almost alone along already also
although always among and another any anybody anyone anything anywhere apos
are area areas around ask asked asking asks at away

back backed backing backs became because become becomes been before began
behind being beings best better between big both but

came can cannot case cases certain certainly clear clearly come could

did differ different differently does done down down downed downing downs
during

each early either end ended ending ends enough even evenly ever every everybody
everyone everything everywhere

face faces fact facts far felt few find finds first for four from full fully
further furthered furthering furthers

gave general generally get gets give given gives going good goods got great
greater greatest group grouped grouping groups

had has have having her here herself high high high higher highest him
himself his how however important interest interested interesting
interests into its itself

just

keep keeps kind knew know known knows

large largely last later latest least less let lets like likely long longer
longest

made make making man many may me member members men might more most mostly
mrs much must myself

nbsp necessary need needed needing needs never new new newer newest next
nobody non noone not nothing now nowhere number numbers

off often old older oldest once one only open opened opening opens order
ordered ordering orders other others our out over

part parted parting parts per perhaps place places point pointed pointing points
possible present presented presenting presents problem problems put puts

quite quot

rather really right right room rooms

said same saw say says second seconds see seem seemed seeming seems sees several
shall she should show showed showing shows side sides since small smaller
smallest some somebody someone something somewhere state states still still
such sure

take taken than that the their them then there therefore these they thing things
think thinks this those though thought thoughts three through thus today together
too took toward turn turned turning turns two

under until upon use used uses

very

want wanted wanting wants was way ways well wells went were what when where
whether which while who whole whose why will with within without work worked
working works would

year years yet you young younger youngest your yours
].to_set

class TweetTokenizer < Wukong::Streamer::RecordStreamer
  RESN = /[@＠][a-zA-Z0-9]{1,20}\b/
  def tokenize text
    return [] if text.blank?
    text = text.gsub(%r{[^[:alpha:]\w\']+}, " ")
    text.gsub!(%r{([[:alpha:]\w])\'([st])},   '\1!\2')
    text.gsub!(%r{[\s\']},         " ")
    text.gsub!(%r{!},              "'")
    text.gsub!(TweetUrl::RE_URL,   " ")
    text.gsub!(RESN,               " ")
    words = text.strip.wukong_encode.split(/\s+/)
    words.reject!{|w| w.blank? || (w.length < 3) }
    words
  end

  def tokenize_text_chunk text_chunk
    return [] if text_chunk.blank?
    text_chunk = text_chunk.wukong_decode.downcase
    tokenize(text_chunk.strip)
  end

  def process *args
    rsrc,tweet_id,created_at,user_id,screen_name,search_id,in_reply_to_user_id,in_reply_to_screen_name,in_reply_to_search_id,in_reply_to_status_id,text,source,lang,lat,lng,retweeted_count,rt_of_user_id,rt_of_screen_name,rt_of_tweet_id,contributors = args
    return if text.count('&') >= 5
    tokenize_text_chunk(text).each do |token_text|
      yield ['word_token', token_text, tweet_id, user_id, created_at] unless STOPWORDS.include?(token_text)
    end
  end

end

Wukong::Script.new(TweetTokenizer, nil).run
