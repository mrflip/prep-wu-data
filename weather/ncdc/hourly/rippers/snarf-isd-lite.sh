rawd=/home/flip/infochimp/rawd/weather
locd=/tmp/weather
datapath=ftp.ncdc.noaa.gov
mkdir -p $locd/$datapath 
# rsync -Curtlp lab1:$locd/$datapath $locd/$datapath
cd $locd

start=${1-1900}
end=${2-2008}
logdir=./ftp.ncdc.noaa.gov/wget-logs/
mkdir -p $logdir
echo 1>&2 "Getting from year $start to year $end"
for ((year=$start; $year<=$end; year++)) ; do
  echo 1>&2 "Getting $year (isd-lite)"
  wget -r -l5  --no-clobber --no-parent  --no-remove-listing  \
    --no-verbose -a $logdir/wget-isd-lite-"$year"-`date +%Y%m%d`.log        \
    --limit-rate=150k \
    ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-lite/$year
done
