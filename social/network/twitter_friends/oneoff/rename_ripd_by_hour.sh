for scrape_session in 2008{11{26,27,28,29,30},12{0,1,2}{1,2,3,4,5,6,7,8,9,0},1230,1231} ; do
    for rsrc in statuses/followers statuses/friends users/show ; do
	ripd_root=/data/ripd/_com/_tw/com.twitter
	cd $ripd_root/_${scrape_session}_old/$rsrc
	for foo in `ruby -e 'puts ("00".."23").to_a.join(" ")'` ; do
	    echo -n "$foo  "
	    mkdir -p ../../../_$scrape_session/_${foo}/${rsrc}
	    mv *+${scrape_session}-${foo}* ../../../_$scrape_session/_${foo}/$rsrc/
	done
    done
done


cd /data/ripd

for foo in _com/_tw/com.twitter/_200????/*/{statuses/followers,statuses/friends,users/show} ; do
    filename=`echo $foo | ruby -ne 'puts $_.chomp.gsub(%r{^_com/_tw/com\.twitter/_(\d+)/_(\d\d)},"\\\\1-\\\\2").gsub(/\W/,"-")'`
    echo $filename
    tar cvjf /data/arch/social/network/twitter_friends/ripd/ripd-$filename.tar.bz2 $foo > /data/log/social/network/twitter_friends/tar-ripd-$filename.log
done


( cd /data/ripd;
  for base in _com/_tw/com.twitter/_2008* ; do
    for foo in $base/*/{statuses/followers,statuses/friends,users/show,followers,statuses/user_timeline}; do
      filename=`echo $foo | ruby -ne 'puts $_.chomp.gsub(%r{^_com/_tw/com\.twitter/_(\d+)/_(\d\d)},"\\\\1-\\\\2").gsub(/\W/,"-")'`;
      tarfile=/data/arch/social/network/twitter_friends/ripd/ripd`basename $base`/ripd-$filename.tar.bz2 ;
      if [ ! -f "$tarfile" -a -e $foo ] ; then
        echo "Creating $tarfile" ; 
	tar cvjf $tarfile $foo /data/log/social/network/twitter_friends/tar-ripd-$filename.log
      else echo -n "skip $filename" ;
      fi ;
    done ;
  done ) &
