#!/usr/bin/env bash

/usr/local/share/hadoop/bin/hadoop 	\
  jar /usr/local/share/hadoop/contrib/streaming/hadoop-*streaming*.jar 	\
  -D mapred.reduce.tasks=1 	\
  -D mapred.task.timeout=10000000 \
  -D mapred.job.name='binned_percentiles_cassandra.rb---/data/sn/tw/fixd/graph/pagerank_with_fo.tsv/data/sn/tw/fixd/graph/fo_percentiles----J-Xmx1024m' 	\
  -mapper  '/usr/bin/jruby -J-Xmx5000m /home/jacob/Programming/infochimps-data/social/network/twitter/projects/trstme/test/binned_percentiles_cassandra.rb --map --hector_home=/usr/local/share/hector' 	\
  -reducer '/usr/bin/jruby -J-Xmx5000m /home/jacob/Programming/infochimps-data/social/network/twitter/projects/trstme/test/binned_percentiles_cassandra.rb --reduce --hector_home=/usr/local/share/hector' 	\
  -input   '/data/sn/tw/fixd/graph/pagerank_with_fo.tsv' 	\
  -output  '/data/sn/tw/fixd/graph/at_percentiles' 	\
  -cmdenv 'RUBYLIB=/home/jacob/Programming/wukong/lib:/home/jacob/Programming/wuclan/lib:/home/jacob/Programming/monkeyshines/lib:/home/jacob/.rubylib'
