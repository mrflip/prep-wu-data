#!/usr/bin/env bash

# resources='users followers friends favorites'
resources="$@"

# File listing all user ids
user_ids_file=rawd/user_ids/user_ids_all.tsv

# Directory for lists of .tar packages to bundles
scrape_store_listing_dir=tmp/scrape_store_listings

for resource in $resources ; do
    listing=${scrape_store_listing_dir}/scrape_store_listings-$resource.tsv
    hdp-rm $listing
    # | grep -v 'supergroup  [ 1-9][0-9]' 
    hdp-ls "arch/ripd/*/*${resource}*" | head -n 12 | hdp-put - $listing 
done

for resource in $resources ; do
    listing=${scrape_store_listing_dir}/scrape_store_listings-$resource.tsv 
    bundled=tmp/bundled_noid/${resource}
    lines=`hdp-cat ${listing} | wc -l`
    hdp-rm -r $bundled
    ./bundle.rb --go --nopartition --sort_keys=2 --map_tasks=${lines} ${listing} ${bundled}
done

for resource in $resources ; do
    bundled_noid=tmp/bundled_noid/${resource}
    bundled=rawd/bundled/${resource}
    hdp-rm -r $bundled
    ./bundle_insert_ids.rb --go --nopartition ${bundled_noid},${user_ids_file} ${bundled}
done

