#!/usr/bin/env bash

#
# Paths
#
for base in tokens_by_hour tokens_by_month ; do

  hdfs_root=fixd/tw/tokens
  arch_root=/mnt/data/arch/com.tw
  arch_dir=com.twitter/${base}
  script_dir=`dirname $0`
  org=infochimps.org-com.twitter
  date=`wu-date`
  handle="${org}-${base}-${date}"

  # Data
  mkdir -p $arch_root/$arch_dir
  echo -e "\n  ********\n Pulling Files from HDFS (${hdfs_root}) into $arch_root/$arch_dir"
  hdp-catd $hdfs_root/${base}               > $arch_root/$arch_dir/${handle}.tsv
  hdp-catd $hdfs_root/total_tokens_by_hour  > $arch_root/$arch_dir/${org}-total_tokens_by_hour-${date}.tsv
  hdp-catd fixd/tw/tweet_metrics/tweet_coverage | tail -n +4 | cuttab 1,2,3 > $arch_root/$arch_dir/${org}-tweet_coverage-${date}.tsv


  # Collateral
  collateral="README.textile ${org}-${base}.icss.yaml"
  echo -e "\n  ********\n Copying over Collateral:\n${collateral}"
  ( cd $script_dir ;
    cp $collateral $arch_root/$arch_dir )

  # Create Archive
  tar_filename=${handle}.tar.bz2
  echo -e "\n  ********\n Creating archive $tar_filename from ${arch_dir}"
  ( cd  $arch_root ; tar cvjf $tar_filename $arch_dir )

done
