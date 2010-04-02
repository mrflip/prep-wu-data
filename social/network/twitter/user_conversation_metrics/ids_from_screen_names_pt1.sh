
# # ===========================================================================
# #
# # Extract relationships
# #
# ~/ics/wuclan/examples/twitter/parse/extract_tweet_tokens.rb --rm --run
#     --reduce_tasks=88
#     fixd/tw/out/search_tweet,fixd/tw/out/tweet fixd/tw/tokens/mention

# # ===========================================================================
# #
# # Split into files
#
# for rel in a_replies_b a_retweets_b a_atsigns_b a_atsigns_b_name a_replies_b_name a_retweets_b_name ; do
#   ~/ics/wukong/bin/hdp-stream2 --rm --map_command="`which egrep` \"^${rel}\"" --ignore_exit_status fixd/tw/tokens/mention fixd/tw/networks/${rel} ;
# done

