#!/usr/bin/env ruby
require 'rubygems'
require 'yaml'

#
# Twitter accepts URLs somewhat idiosyncratically, probably for good reason --
# we rarely see ()![] in urls; more likely in a status they are punctuation.
#
# This is what I've reverse engineered.
#
RE_DOMAIN_HEAD     = '(?:[a-zA-Z0-9\-]+\.)+'
RE_DOMAIN_TLD      = '(?:com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum|[a-zA-Z]{2})'
RE_URL_SCHEME      = '[a-zA-Z0-9\-\+\.]+'
RE_URL_UNRESERVED  = 'a-zA-Z0-9\-\._~'
RE_URL_OKCHARS     = RE_URL_UNRESERVED + '\'\+\,\;' + '/%:@'   # not !$&()* []
RE_URL_QUERY       = RE_URL_OKCHARS + '&='
RE_URL_HOSTPART    = "#{RE_URL_SCHEME}://#{RE_DOMAIN_HEAD}#{RE_DOMAIN_TLD}"
RE_URL             = %r{(#{RE_URL_HOSTPART}(?:/[#{RE_URL_OKCHARS}/]*)?(?:\?[#{RE_URL_QUERY}]+)?(?:#[#{RE_URL_OKCHARS}]+)?)}
#
# A hash following a non-alphanum_ (or at the start of the line
# followed by (any number of alpha, num, -_.+:=) and ending in an alphanum_
#
# This is overly generous to those dorky triple tags (geo:lat=69.3), but we'll soldier on somehow.
#
RE_HASHTAGS        = %r{(?:^|\W)\#([a-zA-Z0-9\-_\.+:=]+\w)(?:\W|$)}
#
# following either the start of the line, or a non-alphanum_ character
# the string of following [a-zA-Z0-9_]
#
RE_ATSIGNS         = %r{(?:^|\W)@(\w+)}


# tests = [
#   'http://foo.us/',
#   'http://foo.us/a',
#   'http://foo.us/a?q=a',
#   'http://foo.us/a#a',
#   'http://foo.us/a?q=a&b=3#a',
#   'http://foo.us/a;2/~m-_.\':%+@,;?q=a&b=3#a',
#   'http://foo.us/a?q=a?',
#   'http://foo.us/=a#a',
#   'http://foo.us/a&?q=a&b=3#a',
#   'http://foo.us/a;2/~m-_.\':%+@,;?q=a&b=3#a&',
# ]
# tests.each do |test_str|
#   p test_str.scan(RE_URL)
# end
#
# atsign_tests = [
#   '@foo hello',
#   ' @foo @hello  ',
#   ' @foo, @hello  ',
#   '-@foo,@hello',
#   '@foo@bar ',
#   'a  basdf@foo b',
#   'http://@foo',
#   'foo@bar @bar@foo @zz+',
# ].each do |test_str|
#   p test_str.scan(RE_ATSIGNS)
# end
#
# hash_tag_tests = [
#   '#downtown',
#   '#downtown?',
#   '#downtown.',
#   '#downtown]',
#   '#downtown}',
#   '#downtown)',
#   '#downtown,',
#   '#downtown;',
#   '#downtown\'',
#   '#downtown\'s',
#   '#downtown_',
#   '#down+town',
#   '#down_town',
#   '#down-town',
#   '#www.downtown.com',
#   '#www.downtown.com.',
#   '##',
#   '#.',
#   '#taxonomy:binomial=Alcedo_atthis',
#   '#geo:lat=52.478342',
#   '#geo:lon=53.609130',
#   'a#www.downtown.com.',
#   ' #www.downtown.com.',
#   ' =#www.downtown.com.!',
# ].each do |test_str|
#   p test_str.scan(RE_HASHTAGS)
# end
#
#
# # #downtown
# # #downtown
# # #downtown
# # #downtown
# # #downtown
# # #downtown
# # #downtown
# # #downtown
# # #downtown
# # #downtown
# # #downtown_
# # #down+town
# # #down_town
# # #down-town
# # #www.downtown.com
# # #www.downtown.com
# #
# #
# # #taxonomy:binomial=Alcedo_atthis
# # #geo:lat=52.478342
# # #geo:lon=53.609130


