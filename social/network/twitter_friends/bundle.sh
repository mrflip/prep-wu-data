#!/usr/bin/env bash
# resources='users followers friends favorites'
resources="$@"

for resource in $resources ; do
  listing=tmp/scrape_store_listings/scrape_store_listings-$resource.tsv
  hdp-rm $listing
  # | grep -v 'supergroup  [ 1-9][0-9]' 
  hdp-ls arch/ripd | grep $resource | hdp-put - $listing 
done

for resource in $resources ; do
   listing=tmp/scrape_store_listings/scrape_store_listings-$resource.tsv 
   bundled=rawd/bundled/${resource}
   lines=`hdp-cat ${listing} | wc -l`
   hdp-rm -r $bundled
   ./bundle.rb --go --nopartition --map_tasks=${lines} ${listing} ${bundled}
 done
