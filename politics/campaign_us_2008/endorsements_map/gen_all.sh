#!/usr/bin/env bash

# diff -uw ripd/endorsements_2008/endorsements-raw-20081030-orig.txt  ripd/endorsements_2008/endorsements-raw-2008-edited.txt > ripd/endorsements_2008/endorsements-raw-2008-patch.diff
./scrape_2008_endorsements.rb

./extract_endorsements_eandp.rb && ./reconcile_newspapers.rb && ./reconcile_circulations.rb && ./gen_endorsements_map.rb && ./gen_endorsements_table.rb
