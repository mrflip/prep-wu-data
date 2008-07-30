sort -rn `dirname $0`/fixd/stats/twitter_ids.txt | ruby -ne 'puts " #{$_}".split(/\s+/)[1]' | uniq -c

# histogram
# twitter_names_hist.sh | tail -n 20
#   36 24
#   47 23
#   67 22
#   49 21
#   68 20
#   83 19
#   94 18
#   89 17
#   88 16
#  102 15
#  120 14
#  136 13
#  154 12
#  199 11
#  255 10
#  260 9
#  352 8
#  468 7
#  612 6
#  800 5
# 1239 4
# 2049 3
# 4458 2
# 17979 1
