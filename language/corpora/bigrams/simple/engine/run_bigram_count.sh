#!/usr/bin/env bash

slug=bnc_athruzonly-2grams

bnc_dir=/data/fixd/language/corpora/word_freq_bnc
bigram_dir=/data/fixd/language/bigrams/simple
script_dir=$(readlink -f `dirname $0`)
dest_dir=$(readlink -f $script_dir/../data)

mkdir -p $bigram_dir $dest_dir

# echo "*** `date` Getting unique word records only "
# time cat $bnc_dir/word_freq_bnc-head-utf8.tsv | tail -n +2 | cuttab 1 | uniq-ord \
#   > $bigram_dir/${slug}-words.tsv

# echo "*** `date` Turning word records into raw bigrams"
# time cat $bigram_dir/${slug}-words.tsv \
#   | $script_dir/count_bigrams.rb --map \
#   > $bigram_dir/${slug}-map_phase.tsv

# echo ; echo "*** `date` Sorting the bigrams with intent to count"
# time sort -S100m $bigram_dir/${slug}-map_phase.tsv \
#   > $bigram_dir/${slug}-sort_phase.tsv 

echo ; echo "*** `date` Counting the bigrams"
time cat $bigram_dir/${slug}-sort_phase.tsv | uniq -c \
  | ruby -ne 'puts $_.chomp.gsub(/^ +/, "").split(/\s+/, 2).reverse.join("\t")' \
  > $bigram_dir/${slug}-counts.tsv

# echo ; echo "*** `date` Counting the bigrams"
# time cat $bigram_dir/${slug}-sort_phase.tsv \
#   | $script_dir/count_bigrams.rb --reduce \
#   > $bigram_dir/${slug}-counts.tsv

echo ; echo "*** `date` Here's the count of raw bigrams"
wc $bigram_dir/${slug}-*.tsv
total=`wc -l $bigram_dir/${slug}-map_phase.tsv | cut -f1 -d' '`

echo ; echo "*** `date` Here's the sum of bigram frequencies using the counts. It should equal the count of raw bigrams, ${total}"
cat $bigram_dir/${slug}-counts.tsv | cuttab 3 | ruby -r'gorillib/some' -e 'puts $stdin.readlines.map{|l| l.to_i }.sum' 

dest_file=$dest_dir/${slug}-freq_ppm.tsv
echo ; echo "*** `date` Turning the counts into frequencies and putting it in the final destination, '$dest_file'"
cat $bigram_dir/${slug}-counts.tsv | sort | ruby -ne 'c1,c2,ct = $_.chomp.split; puts [c1, c2, 1_000_000 * ct.to_f / '$total'.to_f].join("\t")' > $dest_file

echo ; echo "*** `date` Here are the top 10 bigrams, with their ppm (parts per million) frequency! 'e$', 'er' and 'in' should be top, with 'er' at about 16_000 ppm."
sort -rnk3 "$dest_file" | head
