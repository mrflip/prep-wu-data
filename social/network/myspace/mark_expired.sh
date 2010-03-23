#!/usr/bin/env bash

# (1) Need to mark everything for deletion with an "_expired" tag
# (2) Dump the full paths to these files and directories into ONE
#     place. This way the deletion process can simply iterate
#     over the file containing these paths.
#
# Where does everything live that needs to be marked as expired?
# . s3 buckets
# . hadoop cluster
# . s1 scraper
# . s2 scraper
# . local file systems
# We can automate the expiration and deletion of things in s3 buckets
# and on the cluster. Simple cron jobs for the s1 and s2 machines?
# Users should be responsible for their own file systems.

expired_date=`date -v -1m +%Y%m%d` # get date one month prior to today
expired_dir=${expired_date}"/"
tag="_expired"
s3_pkgd="s3n://infochimps-data/data/pkgd/social/network/myspace/"
hdp_rawd="/data/rawd/social/network/myspace/"
s1_ripd="/data/ripd/com.my/com.myspace.api/"
s2_ripd="/data/ripd/com.my/com.myspace.api/"

# only worry about hdp right now
for foo in `hdp-ls ${hdp_rawd}`; do
  if [ ${foo} == ${expired_date} ]; then
    hdp-mv ${hdp_rawd}${foo} ${hdp_rawd}${foo}${tag}
  fi
done

# the problem with s3: cant tag, need to just remove...

