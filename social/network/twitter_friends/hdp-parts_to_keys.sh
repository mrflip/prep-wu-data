#!/usr/bin/env bash

# Killing empty files
find . -size 0 -print -exec rm {} \;

for foo in part-0* ; do
  newname=`
    head -n1 $foo |
    cut -d'	' -f1 |
    ruby -ne 'puts $_.chomp.gsub(/[^\-\w]/){|s| s.bytes.map{|c| "%%%02X" % c }}'
    `.tsv ;
  echo "movine $foo to $newname"
  mv "$foo" "$newname"
done

dir=`basename $PWD`
for foo in *.tsv ; do
  echo "Compressing $dir"
  bzip2 -c $foo > ../$dir-bz2/$foo.bz2 
done
