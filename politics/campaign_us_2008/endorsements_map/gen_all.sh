#!/usr/bin/env bash

# diff -uw ripd/endorsements_2008/endorsements-raw-20081030-orig.txt  ripd/endorsements_2008/endorsements-raw-2008-edited.txt > ripd/endorsements_2008/endorsements-raw-2008-patch.diff
./scrape_2008_endorsements.rb

echo "getting editor&publisher data"		&& ./extract_endorsements_eandp.rb &&
  echo "combining data sources" 		&& ./reconcile_newspapers.rb &&
  # echo "stuffing extended circulation data" 	&&  ./reconcile_circulations.rb &&
  echo "generating map"			 	&&  ./gen_endorsements_map.rb &&
  echo "generating HTML" 			&& ./gen_endorsements_table.rb
