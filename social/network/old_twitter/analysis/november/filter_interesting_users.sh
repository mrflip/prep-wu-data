#!/usr/bin/env bash

# We want to get anyone who
#   used hashtag		#mumbai
#   tweeted words 		mumbai|terror|attack|oberoi|taj
#   has a Indian TZ
#   description or location 	india|paki|bombay|jaipur|delhi|chennai|bangalore|[ck]olkata|calcutta
#      (but not Indiana).
#
#   is in 0th or 1st degree from http://www.mahalo.com/Mumbai_Terrorist_Attack_Twitter
#
#

version=20081222
dump_tweets=fixd/dump/india_tweets-${version}.tsv
dump_tup=fixd/dump/india_users-tup-${version}.tsv
dump_prof=fixd/dump/india_users-prof-${version}.tsv
dump_hashtag=fixd/dump/india_hashtags-${version}.tsv

cat out/${version}-sorted-uff/tweet.tsv			| cut -d'	' -f4- | \
    egrep -i 'mumbai|terror|attack|paki|bombay|india|taj|jaipur|delhi|chennai|bangalore|[ck]olkata|calcutta' \
    > $dump_tweets &
cat out/${version}-sorted-uff/twitter_user_partial.tsv	| cut -d'	' -f6,4,5,10 | ruby -ne 'a=$_.split("\t"); puts a.values_at(2,0,1,3).join("\t")' | uniq -f1 | \
    egrep -i '(india|pakistan|mumbai|bombay)' 	  | egrep -vi indiana \
    > $dump_tup &
cat out/${version}-sorted-uff/twitter_user_profile.tsv	| cut -d'	' -f 3,4,7,8,9,10 |	\
    egrep -i '(	19|india|pakistan|mumbai|bombay)' | egrep -vi indiana \
    > $dump_prof &
cat out/${version}-sorted-uff/hashtag.tsv                 | cut -d'	' -f 3- 	       | \
    egrep -i 'mumbai|terror|attack|paki|bombay|india|taj|jaipur|delhi|chennai|bangalore|[ck]olkata|calcutta'  \
    > $dump_hashtag &


( cut -f2 -d'	' $dump_tup  ; cut -f2 -d'	' $dump_prof ; cut -f3 -d'	' $dump_tweets ; cut -f2 -d'	' $dump_hashtag ) | \
    sort -u > fixd/dump/india_ids.tsv
