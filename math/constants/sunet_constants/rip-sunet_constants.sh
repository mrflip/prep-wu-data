
#
# Snarf interesting files from ftp://ftp.sunet.se/ FTP repository
#

wget -r -l5  --no-remove-listing --timestamping --no-parent                   	\
    --no-verbose --background -a wget-`date +%Y%m%d`.log 	\
    -erobots=off --wait=0.5 --random-wait --limit-rate=100k	\
    ftp://ftp.sunet.se/pub/Science/constant/ ftp://ftp.sunet.se/pub/Science/molbio/  \
    ftp://ftp.sunet.se/pub/Science \
    ftp://ftp.sunet.se/ls-lR.gz
