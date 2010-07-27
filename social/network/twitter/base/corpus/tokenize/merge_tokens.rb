#!/usr/bin/env ruby

#
# Move newly unspliced tokens to the temporary parse bucket (/data/sn/tw/rawd/azkaban/unspliced)
#

unspliced_tokens = ARGV[0]
output_dir       = ARGV[1]

%w[ hashtag smiley tweet_url stock_token a_replies_b ].each do |token|
  existing_token_dir = File.join(unspliced_tokens, token)
  desired_token_dir  = File.join(output_dir, token)
  next unless system %Q{hadoop fs -test -e #{existing_token_dir}}
  system %Q{hdp-mv #{existing_token_dir} #{desired_token_dir}}
end
