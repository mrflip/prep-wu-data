#!/bin/sh 
# TinyCC main script for UNIX 
# by Chris Biemann
# Version 2.1


# Version 1:  March 2006
# Version 2:  February 2007
#  - included text2satz by Fabian Schmidt
#  - included sources handling and conversions
# Version 2.1: August 2007
#  - included some fixes for handling UTF-8 text by Matthias Richter
# Version 2.1.1: October 2007
#  - included Urdu support by Matthias Richter
# Contact: biem@informatik.uni-leipzig.de
#
# for indexing and computing co-occurrences for small and medium-sized corpora

# this script takes 3 parameters:
# - a name prefix for the corpus $1, e.g. "mycorpus"
# - a directory where texts are stored: $2 
# - a multi word unit list, one MWU per line $3 (or "none")


# and writes 7 files into the folder "result":
# - $1.sentences:   s_id <tab> sentence
# - $1.words     w_id <tab> word <tab> frequency
# - $1.inv_w        w_id <tab> s_id <tab> pos [- if part of following MWU]
# - $1.co_s        w1_id <tab> w2_id <tab> freq <tab> sig
# - $1.co_n        w_1id <tab> w2_id <tab> freq <tab> sig
# - $1.inv_so    s_id <tab> so_id
# - $1.sources    so_id <tab> sourcename

# As input, the files in the specified folder can be given as
# - plain text  (source names are file names)
# - HTML        (source names are file names)
# - satz.s-format (source-names are read from <quelle>-tag 

# input text is in format (latin|utf8)
export TEXTFORM=utf8
# locales for latin__must__ be installed on your system!
# See `localedef --list-archive` for a list of installed locales
# Edit /etc/locale.gen and  sudo locale-gen to enable specific locales

# locale to be used for processing ISO 8859 text
export LTYPE=de_DE@euro
# name of this locale as understood by `recode`
export LNAME=latin1

# locale to be used for processing UTF-8 text
export UTYPE=de_DE.UTF-8

# Memory max usage in MB (approximate)
export MAXMEM=600
# min frequency for scoocs
export SMINFREQ=2
# min sig for scooc
export SMINSIG=6.63
# min freq for nbcooc
export NMINFREQ=2
# min sig for NBcooc
export NMINSIG=3.84
# number of digits after .
export DIGITS=2
# temp directory
export TEMP=temp
# result directory
export RES=result

echo "preparing directories"
mkdir $TEMP
rm $TEMP/*
mkdir $RES


echo "Collecting texts and converting..."
if [ $TEXTFORM = "latin" ]
then
   export LANG=$LTYPE
   java -jar bin/text2satz.jar -n -d $1 -a bin/abbrev -e -p $TEMP/ $2
   echo "[Text2Satz] done"
else
   export LANG=$UTYPE
   java -jar bin/text2satz.jar -n -d $1 -a bin/abbrev -e -p $TEMP/ $2
   if [ `which recode` ]
   then
      echo "[Text2Satz] Fixing encoding errors"
      `which recode` -f utf8..${LNAME} $TEMP/$1.s
   else
      echo "[Text2Satz] You need to have installed recode in your \$PATH!"
      echo "[Text2Satz] no recode found: Your results will look garbled."
   fi
fi

# -n: Newline is always sentence break. -a: abbreviation list. These words can be followed by "." without a sentence split. 
mv $TEMP/sentsrc.txt $RES/$1.inv_so
mv $TEMP/sources.txt $RES/$1.sources
echo "Numbering sentences..."
perl perl/numberIt.pl $TEMP/$1.s > $RES/$1.sentences
echo "Tokenizing ... "
if [ $TEXTFORM = "latin" ]
then
   perl perl/tokenize.pl $RES/$1.sentences $TEMP/$1.tok
   perl perl/tok_multiwords.pl $3 $TEMP/$3.tok
else
   perl perl/tokenize_utf8.pl $RES/$1.sentences $TEMP/$1.tok
   perl perl/tok_multiwords_utf8.pl $3 $TEMP/$3.tok
fi
echo "Collecting single words ..."
perl perl/freqSingle.pl $TEMP/$1.tok $TEMP/$1.singlewords
echo "Collecting and counting all words .."
perl perl/freqMulti.pl $TEMP/$1.singlewords $TEMP/$3.tok $TEMP/$1.tok $TEMP/$1.words
echo "Indexing ..."
if [ $TEXTFORM = "latin" ]
then
   perl perl/index_wl.pl $TEMP/$1.words $TEMP/$1.tok $TEMP/$1
else
   perl perl/index_wl_utf8.pl $TEMP/$1.words $TEMP/$1.tok $TEMP/$1
fi
cp $TEMP/$1.index $RES/$1.inv_w
echo "Calculating neighbour co-occurrences"
perl perl/nbcooc.pl $TEMP/$1.wordlist_tok $TEMP/$1.index $MAXMEM $NMINFREQ $NMINSIG $DIGITS $RES/$1.co_n
echo "Calculating sentence co-occurrences"
echo "- collecting pairwise frequencies"
perl perl/sfreq.pl $TEMP/$1.wordlist_tok $TEMP/$1.index $MAXMEM $SMINFREQ $TEMP/$1
echo "- sorting pairwise frequencies"
./bin/sort64 --buffer-size=${MAXMEM}M -T . -k1n -k2n $TEMP/$1.sfreqtemp -o $TEMP/$1.sfreqtempsort
echo "- adding frequencies"
perl perl/add3col_sym.pl $TEMP/$1.sfreqtempsort $SMINFREQ $TEMP/$1.sfreq
echo "- computing significances"
perl perl/ssig.pl $TEMP/$1.wordlist_tok $TEMP/$1.index $TEMP/$1.sfreq $SMINSIG $DIGITS $RES/$1.co_s
echo "De-tokenizing word list"
if [ $TEXTFORM = "latin" ]
then
   perl perl/detok_multiwords.pl $TEMP/$1.wordlist_tok $RES/$1.words
else
   perl perl/detok_multiwords_utf8.pl $TEMP/$1.wordlist_tok $RES/$1.words
fi
echo "Cleaning up ..."
# rm $TEMP/*
echo "Done !"

exit;
