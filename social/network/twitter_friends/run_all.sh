#!/usr/bin/env bash

# ./bundle.sh user favorites friends followers

for rsrc in friends followers user favorites public_timeline ; do
  hdp-rm -r fixd/$rsrc
  ./parse_json.rb --go --$rsrc rawd/bundled/$rsrc fixd/$rsrc
done

# for rsrc in user followers friends favorites public_timeline ; do
#   hdp-rm -r fixd/rdfified/$rsrc
#   ./rdfify.rb     --go         fixd/$rsrc         fixd/rdfified/$rsrc 
# done

all_src_files=fixd/user,fixd/friends,fixd/followers,fixd/favorites,fixd/public_timeline
dest=fixd/text_elements
hdp-rm -r $dest
./grokify.rb --go $all_src_files $dest
