#!/usr/bin/env sh
url='http://msds.chem.ox.ac.uk/'

for ltr in {a..z}
do
  wget -nc -r -nv -l 2 ${url}${ltr}dir.html
done
