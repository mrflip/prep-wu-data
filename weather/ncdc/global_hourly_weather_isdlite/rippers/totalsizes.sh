#!/bin/bash
dir=$HOME/infochimp/rawd/weather/ftp.ncdc.noaa.gov/pub/data/noaa/isd-lite
meta_dir=$HOME/infochimp/rawd/weather/meta/isd-lite

what="isd-lite"
mkdir -p $meta_dir
pushd $dir

( for foo in */.listing ; do
    echo $foo | perl -pe 'chomp; s!.*/([^/]+)/\.listing!$1!'
    cat $foo       |
      cut -c 29-42 |
      perl -e '
        @sizes = <>;
        map { $total += $_ } @sizes;
        printf "     \t%12s\t%10.3f MiB\n",
          $total, (1.0*$total)/(2**20);
      '
  done ) > $meta_dir/${what}_sizes_by_year.txt

# for foo in [12]* ; do
#   ls -ls $foo | tail -n +2 |
#     perl -ne 'chomp; s/^(?:[\w\-]+\s+){5}(\d+)\s+(?:[\-\:\w]+\s+){2}(.*)/$1\t$2\n/; print "$1\t$2\n"' > \
#     $meta_dir/received/$foo.received.txt
# done
# for foo in [12]*/.listing ; do
#   cat $foo |
#     perl -ne 'chomp; s/^(?:[\w\-]+\s+){4}(\d+)\s+(?:\w+\s+){3}(.*)/$1\t$2\n/; print' > \
#     $meta_dir/listings/`dirname $foo`.listing.txt
# done

popd

pushd $meta_dir
( for ((yr=190; $yr<201; yr++)) ; do
        echo -n $yr ;
        cat $meta_dir/${what}_sizes_by_year.txt |
        egrep "^$yr" | cut -f2 |
        perl -e '@sizes = <>; map { $total += $_ } @sizes; printf "   \t%12s\t%10.3f MiB\n", $total, (1.0*$total)/(2**20);' ;
  done )

# ===========================================================================
#
# isd-lite:
#
# 190           540811         0.516 MiB
# 191           705114         0.672 MiB
# 192           969509         0.925 MiB
# 193         50338999        48.007 MiB
# 194        341545686       325.723 MiB
# 195        911245151       869.031 MiB
# 196        847554623       808.291 MiB
# 197       1770214197      1688.208 MiB
# 198       2751762023      2624.285 MiB
# 199       3156169604      3009.958 MiB
# 200       3346706145      3191.668 MiB
# total    13177751862     12567.283 MiB

# ===========================================================================
# 
# ( for yr in '19[0-5]' '19(6|7[0-3])' '197[4-9]' '198[0-4]' '198[5-9]' '199[0-3]' '199[4-7]' '199[89]|2000' '200[12]' '200[3-4]' '200[5]' 200[6] 200[7] ; do echo -n $yr  ; cat ncdc-global-hourly/ncdc-global-hourly_SizeByYear.txt | egrep "^$yr" | cut -f2 |  perl -e '@sizes = <>; map { $total += $_ } @sizes; printf "   \t%12s\t%10.3f MiB\n", $total, (1.0*$total)/(2**20);' ; done )
# 19[0-5]           3443836140      3284.298 MiB
# 19(6|7[0-3])      3312296491      3158.852 MiB
# 197[4-9]          4618440798      4404.488 MiB
# 198[0-4]          4196323649      4001.926 MiB
# 198[5-9]          4747577097      4527.642 MiB
# 199[0-3]          4078141681      3889.219 MiB
# 199[4-7]          4031929710      3845.148 MiB
# 199[89]|2000      4246768179      4050.034 MiB
# 200[12]           4296407651      4097.374 MiB
# 200[3-4]          5146673873      4908.251 MiB
# 200[5]            3011246064      2871.748 MiB
# 200[6]            3012965006      2873.387 MiB
# 200[7]            3116192302      2971.833 MiB

# 190x          590271         0.563 MiB
# 191x          817046         0.779 MiB
# 192x         1512842         1.443 MiB
# 193x       101134028        96.449 MiB
# 194x       760891743       725.643 MiB
# 195x      2578890210      2459.421 MiB
# 196x      2221103169      2118.209 MiB
# 197x      5709634120      5445.131 MiB
# 198x      8943900746      8529.568 MiB
# 199x     10447016906      9963.052 MiB
# 200x     20784110717     19821.273 MiB
