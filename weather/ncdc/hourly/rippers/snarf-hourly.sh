start=${1-2005}
end=${2-2006}
echo 1>&2 "Getting from year $start to year $end"
for ((year=$start; $year<=$end; year++)) ; do
  echo 1>&2 Getting $year
  wget -r -l5  --no-clobber --no-parent  --no-remove-listing  \
    --no-verbose -a ./ftp.ncdc.noaa.gov/wget-"$year"-`date +%Y%m%d`.log        \
     --limit-rate=150k     \
    ftp://ftp.ncdc.noaa.gov/pub/data/noaa/$year
done
