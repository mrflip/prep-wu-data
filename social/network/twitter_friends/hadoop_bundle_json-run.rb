data_root=/workspace/flip/data
rawd=$data_root/rawd/
rawd=$rawd_root/social/network/twitter_friends
ripd=$data_root/ripd/_com/_tw/com.twitter/

ripd_filenames=$rawd/ripd_files-`date +%Y%m%d%H%M%S`
find  -type f > $ripd_filenames

