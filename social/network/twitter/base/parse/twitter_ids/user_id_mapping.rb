#!/usr/bin/env ruby

#
# Goes through the gory logic of creating the user table
#
# Check that all paths exist, substitute with existing (old) paths if necessary. Fail obviously.
#

# the directory containing newly unspliced twitter objects
unspliced = ARGV[0]
# the directory containing previously normalized twitter objects
existing  = ARGV[1]

#
# Fails obviously if neither dir exists
#
def extract_ids_from_a_follows_b unspliced, existing
  a_follows_b = File.join(unspliced, "a_follows_b")
  exists = system %Q{ hadoop fs -test -e #{a_follows_b} }
  a_follows_b = File.join(existing, "a_follows_b") unless exists
  status = system %Q{pig -p REL=#{a_follows_b} -p RAW_REL_IDS_FILE=/tmp/all_seen_users/raw_rel_ids #{File.dirname(__FILE__)}/extract_ids_from_rel.pig}
  exit status unless status
end

def extract_uid_sn_mapping unspliced, existing
  tweet = File.join(unspliced, "tweet")
  exists = system %Q{ hadoop fs -test -e #{tweet} }
  tweet = File.join(existing, "tweet") unless exists
  status = system %Q{pig -p TWEET_FILE=#{tweet} -p RAW_ID_SNS_FILE=/tmp/all_seen_users/raw_id_sns #{File.dirname(__FILE__)}/extract_uid_sn_mapping.pig}
  exit status unless status
end

def assemble_twitter_user_id unspliced, existing
  twitter_user_id = File.join(unspliced, "twitter_user_id")
  exists = system %Q{ hadoop fs -test -e #{twitter_user_id} }
  twitter_user_id = File.join(existing, "twitter_user_id") unless exists

  twitter_user_search_id = File.join(unspliced, "twitter_user_search_id")
  exists = system %Q{ hadoop fs -test -e #{twitter_user_search_id} }
  twitter_user_search_id = File.join(existing, "twitter_user_search_id") unless exists

  status = system %Q{pig -p TW_UID=#{twitter_user_id} -p TW_SID=#{twitter_user_search_id} -p RAW_REL_IDS_FILE=/tmp/all_seen_users/raw_rel_ids -p RAW_ID_SNS_FILE=/tmp/all_seen_users/raw_id_sns -p MAPPING=/tmp/all_seen_users/all_user_info #{File.dirname(__FILE__)}/assemble_id_mapping.pig}
  exit status unless status
end

extract_ids_from_a_follows_b unspliced, existing
extract_uid_sn_mapping unspliced, existing
assemble_twitter_user_id unspliced, existing
