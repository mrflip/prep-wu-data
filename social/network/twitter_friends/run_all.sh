#!/usr/bin/env bash

./bundle.sh   user favorites followers friends user_timeline

for rsrc in   user favorites followers friends user_timeline public_timeline ; do
  hdp-rm -r fixd/$rsrc
  ./parse_json.rb --go rawd/bundled/$rsrc fixd/$rsrc
done

all_src_files=fixd/user,fixd/favorites,fixd/followers,fixd/friends,fixd/user_timeline,fixd/public_timeline
dest=fixd/text_elements
hdp-rm -r $dest
./grokify.rb --go $all_src_files $dest


dest=fixd/flattened 
hdp-rm -r $dest 
./uniq_by_last.rb --go --flatten_keys $all_src_files,fixd/text_elements fixd/all

for rsrc in fixd/all ; do
  hdp-rm -r fixd/rdfified/$rsrc
  ./rdfify.rb     --go         fixd/$rsrc         fixd/rdfified/$rsrc 
done
