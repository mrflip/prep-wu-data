sort -rn twitter_ids.txt | ruby -ne 'puts " #{$_}".split(/\s+/)[1]' | uniq -c
