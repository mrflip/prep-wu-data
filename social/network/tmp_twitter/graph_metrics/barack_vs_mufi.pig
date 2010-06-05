-- libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- defaults
%default MUFI_ID '23866990' ;
%default BARACK_ID '813286' ;
%default PAGERANK '/data/rawd/social/network/twitter/pagerank/a_follows_b_pagerank/pagerank_only' ;
%default BARACK_OUTPUT '/data/anal/social/network/twitter/barack_vs_mufi/barack_followers_pageranks' ;
%default MUFI_OUTPUT '/data/anal/social/network/twitter/barack_vs_mufi/mufi_followers_pageranks' ;
%default A_FOLLOWS_B '/data/rawd/social/network/twitter/objects/a_follows_b' ;

a_follows_b = LOAD '$A_FOLLOWS_B' AS (foobar:chararray, user_a_id:long, user_b_id:long);
pagerank    = LOAD '$PAGERANK' AS (user_id:long, pagerank:float);

mufi_follow = FILTER a_follows_b BY user_b_id == $MUFI_ID;
mufi_follower_id   = FOREACH mufi_follow GENERATE user_a_id AS id:long;
mufi_follower_id_joined_pagerank = JOIN mufi_follower_id BY id, pagerank BY user_id;
mufi_follower_id_and_pagerank = FOREACH mufi_follower_id_joined_pagerank GENERATE mufi_follower_id::id, pagerank::pagerank;
rmf $MUFI_OUTPUT
STORE mufi_follower_id_and_pagerank INTO '$MUFI_OUTPUT';

barack_follow = FILTER a_follows_b BY user_b_id == $BARACK_ID;
barack_follower_id = FOREACH barack_follow GENERATE user_a_id AS id:long;
barack_follower_id_joined_pagerank = JOIN barack_follower_id BY id, pagerank BY user_id;
barack_follower_id_and_pagerank = FOREACH barack_follower_id_joined_pagerank GENERATE barack_follower_id::id, pagerank::pagerank;
rmf $BARACK_OUTPUT
STORE barack_follower_id_and_pagerank INTO '$BARACK_OUTPUT';











