#!/usr/bin/env bash

/usr/local/share/hadoop/bin/hadoop 	\
  jar /usr/local/share/hadoop/contrib/streaming/hadoop-*streaming*.jar 	\
  -D num.key.fields.for.partition=2 	\
  -D stream.num.map.output.key.fields=3 	\
  -D mapred.reduce.tasks=0 	\
  -D mapred.job.name='extract_tweet_tokens.rb---/data/sn/tw/fixd/objects/tweet---/data/terms/tdidf/word_token' 	\
  -D mapred.job.reuse.jvm.num.tasks=-1 	\
  -mapper  '/usr/bin/ruby1.8 /home/jacob/Programming/infochimps-data/social/network/twitter/base/corpus/tokenize/extract_tweet_tokens.rb --map --io_record_percent=0.4' 	\
  -reducer '' 	\
  -input   '/data/sn/tw/fixd/objects/tweet' 	\
  -output  '/data/terms/tdidf/word_token' 	\
  -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner 	\        
  -cmdenv 'RUBYLIB=~/.rubylib:~/Programming/imw/lib:~/Programming/wukong/lib:~/Programming/wuclan/lib:~/Programming/classifier/lib:/opt/local/lib/ruby/vendor_ruby/1.8/i686-darwin10/:/home/jacob/Programming/wukong/lib:/home/jacob/Programming/wuclan/lib:/home/jacob/Programming/monkeyshines/lib:/home/jacob/.rubylib'
