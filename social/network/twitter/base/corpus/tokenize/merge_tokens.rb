#!/usr/bin/env ruby

#
# Merge newly unspliced tokens with existing ones
#

unspliced    = ARGV[0]
old_tokens   = ARGV[1]
new_tokens   = ARGV[2]

def construct_paths token, unspliced, old_tokens, new_tokens
  new_token_dir      = File.join(unspliced, token)
  existing_token_dir = File.join(old_tokens, token)
  return unless system %Q{hadoop fs -test -e #{new_token_dir}}
  # Here we expect the old tokens and new tokens to be in the same place
  if system %Q{hadoop fs -test -e #{existing_token_dir}}
    system %Q{hadoop fs -mv #{existing_token_dir} #{existing_token_dir}_prior}
    existing_token_dir += "_prior"
    inputdirs  = [new_token_dir, existing_token_dir].join(",")
  else
    inputdirs  = new_token_dir
  end
  outputdir  = File.join(new_tokens, token)
  [inputdirs, outputdir]
end

%w[ a_replies_b a_atsigns_b_name a_retweets_b_name hashtag smiley tweet_url stock_token ].each do |token|
  paths = construct_paths token, unspliced, old_tokens, new_tokens
  next unless paths
  system %Q{hdp-stream #{paths.first} #{paths.last} `which cat` `which uniq` 2 3 -jobconf mapred.map.tasks.speculative.execution=false; true}
end
