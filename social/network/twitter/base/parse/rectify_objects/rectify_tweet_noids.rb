#!/usr/bin/env ruby


TWTS    = "/data/sn/tw/fixd/tweet"
TWTSCLN = "/data/sn/tw/fixd/tweet-finished"
TWNOIDS = "/data/sn/tw/fixd/objects/tweet-noid"
TWUSERS = "/data/sn/tw/fixd/user_table"
TWRECT  = "/data/sn/tw/fixd/objects/tweet-rectified"
TWFAIL  = "/data/sn/tw/rawd/to_scrape/tweet-noid"
TWRFIXD = "/data/sn/tw/fixd/objects/tweet-replies-rectified"
TWGOOD  = "/data/sn/tw/fixd/objects/tweet-good"
TWRBAD  = "/data/sn/tw/fixd/objects/tweet-no-reply-id"

#
# Run the first pass over tweet-noid
#
def run_first_pass
  system %Q{ echo pig -param TWNOID=#{TWNOIDS} -param TABLE=#{TWUSERS} -param TWFIXD=#{TWRECT} -param FAIL=#{TWFAIL} rectify_tw_noids_first_pass.pig }
  system %Q{ echo hdp-rm -r #{TWNOIDS} }
end

#
# Run the second pass
#
def run_second_pass
  system %Q{ echo pig -param TABLE=#{TWUSERS} -param TWFIXD=#{TWRECT} -param TWGOOD=#{TWGOOD} -param TWRFIXD=#{TWRFIXD} -param TWRBAD=#{TWRBAD} rectify_tw_noids_second_pass.pig }
  system %Q{ echo hdp-rm -r #{TWRECT} }
end

#
# Take rectified tweets and existing tweets and tumble them.
# Remove once finished and end up with a final tweet directory
#
def tumble_tweets
  system %Q{ echo hdp-stream #{TWTS},#{TWGOOD},#{TWRFIXD} #{TWTSCLN} `which cat` `which uniq` 2 3 -jobconf mapred.map.tasks.speculative.execution=false }
  system %Q{ echo hdp-rm -r #{TWTS} }
  system %Q{ echo hdp-rm -r #{TWGOOD} }
  system %Q{ echo hdp-rm -r #{TWRFIXD} }
  system %Q{ echo hdp-mv #{TWTSCLN} #{TWTS} }
end

run_first_pass
run_second_pass
tumble_tweets
