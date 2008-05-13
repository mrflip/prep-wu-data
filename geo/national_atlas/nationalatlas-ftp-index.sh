# First I used https://www.squarefree.com/bookmarklets/webdevel.html "Displays the current DOM tree of the page as HTML"
# then I munged the resulting .html file with
  cat nationalatlas-ftp-index.html | perl -ne 'm!href="(.*?)"!g && do { $a=$1; $a=~s!^\./!http://nationalatlas.gov/!gi; print "$a\n"};' | grep -v javascript > nationalatlas-ftp-index.txt
# then snarfed with
  wget -nc -np --background -a wget-`date +%Y%m%d`.log  --wait=0.5 --random-wait --limit-rate=100k -i nationalatlas-ftp-index.txt -x

