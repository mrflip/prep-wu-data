#!/usr/bin/env bash

TODAY=`date "+%Y%m%d"`
BKUP_DIR='/data/hadoop/hdfs/name/backup'

# for now the namenode is set manually.  if the cluster master/namenode changes, this will need to be changed
NAMENODE='ec2-204-236-225-16.compute-1.amazonaws.com'

mkdir -p $BKUP_DIR/$TODAY
wget http://$NAMENODE:50070/getimage?getimage=1 -O $BKUP_DIR/$TODAY/fsimage
wget http://$NAMENODE:50070/getimage?getedit=1 -O $BKUP_DIR/$TODAY/edits