

wget -r -l5 -S --no-clobber --timeout=2 --no-parent \
    --verbose -erobots=off \
    --wait=5 --random-wait --limit-rate=100k \
    -a wget-`date +%Y%m%d`-eh.net.log \
    http://eh.net/databases
