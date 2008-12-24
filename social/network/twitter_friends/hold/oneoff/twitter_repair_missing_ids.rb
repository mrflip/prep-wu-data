
CREATE TEMPORARY TABLE fix_ids ( screen_name VARCHAR(20), id INTEGER UNSIGNED ) ;
LOAD DATA INFILE '~/ics/pool/social/network/twitter_friends/fixd/dump/missing_ids_to_scrape.tsv' INTO TABLE fix_ids ;

SELECT fix.screen_name, tup.id, tup.followers_count
  FROM          fix_ids fix
  LEFT JOIN     twitter_user_partials tup
        ON      fix.screen_name = tup.screen_name
  WHERE         tup.id IS NOT NULL
  INTO OUTFILE '~/ics/pool/social/network/twitter_friends/fixd/dump/user_names_and_ids_missing.tsv'
