/bin/ls -1 | perl -ne 's/(\d\ds\d+)\..*/$1/; print' | sort -u
