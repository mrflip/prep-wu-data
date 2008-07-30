src_root="/tmp/weather"
dest_root="~/ics/data/ripd"
sync_dir="ftp.ncdc.noaa.gov/pub/data"
dest_host="$WEB"
ssh "$dest_host" "mkdir -p ${dest_root}/$sync_dir/"
log="$src_root/log"
mkdir -p "$log"
outplog="$log/rsync-`date '+%Y%m%d'`-outp.log"
synclog="$log/rsync-`date '+%Y%m%d'`-log.log"

cd "$src_root"
foo=$sync_dir
# for foo in $sync_dir/inventories $sync_dir/noaa/isd-lite/200* ; do
   cmd="rsync -Cuvzrtlp $src_root/$foo/ $dest_host:$dest_root/$foo/ --bwlimit=250 --partial --size-only --log-file=$synclog"
   echo $cmd
   $cmd 2>&1 >>$outplog
# done
