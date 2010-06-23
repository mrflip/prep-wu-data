#!/usr/bin/env ruby

#
# Problem: A user queries their trstrank but it isn't in our db. What do we
# do short of rerunning the entire f*ing algorithm?
#
# Solution: Fetch user A's followers list. Join A's 'followers list against the
# pr table pulling out a list of followers, their pr as well as the number of
# followers. We can then run through each of user A's followers and calculate
# the amount of pr they are capable of bestowing. Add this up and you've got a
# rough (but quick) estimate of trstrank.
#

#
# ? Make a request to twitter api and get list of followers as json
#
def fetch_follower_ids user_id
end

#
# Parse json follower ids using wuclan
#
def parse_follower_ids
end

#
# Store flat followers list on hdfs
#
def store_followers_on_hdfs path
end

#
# Run mapside join, using pig, against trstrank table. Need
# to pull out user_id, raw rank, num_friends. Calculate from
# this the pr each follower is capable of bestowing. Add this
# column up and store. Finally, read out this value.
#
def pig_fetch_trstrank path, path_to_trstrank
end

#
# Jsonize this user and their newly acquired trstrank
#
def create_jsonized_record
end

#
# Store jsonzed record and user_id into apeyeye db
#
def store_user_trstrank user, json
end
