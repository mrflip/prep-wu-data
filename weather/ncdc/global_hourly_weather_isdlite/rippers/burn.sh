srcdir=$HOME/infochimp/rawd/weather/ftp.ncdc.noaa.gov/
localdir=/tmp/weather/ftp.ncdc.noaa.gov/
rsync -Curtlp $srcdir $localdir

pushd $localdir

# burn=/tmp/weather/burn/part1/ftp.ncdc.noaa.gov/
# mkdir -p $burn/pub/data/noaa/isd-lite/
# ln -s $localdir/wget-logs               		$burn/wget-logs
# ln -s $localdir/pub/data/inventories    		$burn/pub/data/
# ln -s $localdir/pub/data/noaa/*.*       		$burn/pub/data/noaa/
# ln -s $localdir/pub/data/noaa/isd-lite/19[0-6]*  	$burn/pub/data/noaa/isd-lite/
# ln -s $localdir/pub/data/noaa/isd-lite/197[0-6]*	$burn/pub/data/noaa/isd-lite/
# 
# burn=/tmp/weather/burn/part2/ftp.ncdc.noaa.gov/
# mkdir -p $burn/pub/data/noaa/isd-lite/
# ln -s $localdir/pub/data/noaa/isd-lite/197[789]*	$burn/pub/data/noaa/isd-lite/
# ln -s $localdir/pub/data/noaa/isd-lite/198*    	$burn/pub/data/noaa/isd-lite/
# 
# burn=/tmp/weather/burn/part3/ftp.ncdc.noaa.gov/
# mkdir -p $burn/pub/data/noaa/isd-lite/
# ln -s $localdir/pub/data/noaa/isd-lite/199*    	$burn/pub/data/noaa/isd-lite/
# ln -s $localdir/pub/data/noaa/196[0-1]*		$burn/pub/data/noaa/
# 
# burn=/tmp/weather/burn/part4/ftp.ncdc.noaa.gov/
# mkdir -p $burn/pub/data/noaa/isd-lite/
# ln -s $localdir/pub/data/noaa/isd-lite/200*   	$burn/pub/data/noaa/isd-lite/
# ln -s $localdir/pub/data/noaa/196[2-3]*		$burn/pub/data/noaa/isd-lite/
# 
# burn=/tmp/weather/burn/part5/ftp.ncdc.noaa.gov/
# mkdir -p $burn/pub/data/noaa/isd-lite/
# ln -s $localdir/pub/data/noaa/19[0-5]*		$burn/pub/data/noaa/
# ln -s $localdir/pub/data/noaa/196[4-6]*   		$burn/pub/data/noaa/
# 
# burn=/tmp/weather/burn/part6/ftp.ncdc.noaa.gov/
# mkdir -p $burn/pub/data/noaa/isd-lite/
# ln -s $localdir/pub/data/noaa/196[6-9]*		$burn/pub/data/noaa/
# ln -s $localdir/pub/data/noaa/197[0-6]*		$burn/pub/data/noaa/
# 
# burn=/tmp/weather/burn/part7/ftp.ncdc.noaa.gov/
# mkdir -p $burn/pub/data/noaa/isd-lite/
# ln -s $localdir/pub/data/noaa/197[7-9]*		$burn/pub/data/noaa/
# ln -s $localdir/pub/data/noaa/198*    		$burn/pub/data/noaa/
# ln -s $localdir/pub/data/noaa/199*    		$burn/pub/data/noaa/
# ln -s $localdir/pub/data/noaa/200*    		$burn/pub/data/noaa/
# 
# for foo in /tmp/weather/burn/* ; do du -sL $foo ; done

isodir=/tmp/weather/isos
mkdir -p $isodir
for foo in 1 2 3 4 5 6 7 ; do
    cd /tmp/weather/burn/part${foo}
    mkisofs   -v -JrUTD -f -udf -max-iso9660-filenames -V weather-${foo} -o $isodir/dvd-weather-${foo}.iso ./
done

for foo in 1 2 3 4 5 6 7  ; do
    growisofs -speed=6 -Z /dev/dvd=$isodir/dvd-weather-${foo}.iso
done
