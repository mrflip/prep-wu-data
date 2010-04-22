-- libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- parameters
%default PAGERANK_THRESHOLD '2.2262';

-- input paths
%default PAGERANK '/data/rawd/social/network/twitter/pagerank/a_follows_b_pagerank/pagerank_only' ;
%default A_FOLLOWS_B '/data/rawd/social/network/twitter/objects/a_follows_b' ;

-- output paths
%default PAGERANK_OUTPUT    '/data/rawd/social/network/twitter/pagerank/a_follows_b_pagerank/pagerank_thresholded';
%default A_FOLLOWS_B_OUTPUT '/data/rawd/social/network/twitter/pagerank/a_follows_b_pagerank/a_follows_b_thresholded';

-- load
all_a_follows_b = LOAD '$A_FOLLOWS_B' AS (foobar:chararray, user_a_id:long, user_b_id:long);
all_pagerank    = LOAD '$PAGERANK' AS (user_id:long, value:float);

-- grab top pageranks & links
pagerank = FILTER all_pagerank BY value >= $PAGERANK_THRESHOLD;

-- store
rmf $PAGERANK_OUTPUT;
STORE pagerank INTO '$PAGERANK_OUTPUT';

-- grab all links where follower has high pagerank (includes where friend has low)
--   [user_id, pagerank] join [user_a_id, user_b_id] => [user_id, pagerank], [user_id, user_b_id]
pagerank_join_follow_a_high = JOIN pagerank BY user_id, all_a_follows_b BY user_a_id;
--   [user_id, pagerank], [user_id, user_b_id] => [d0_id, user_b_id]
follow_a_high               = FOREACH pagerank_join_follow_a_high GENERATE
	all_a_follows_b.user_a_id AS d0_id,
	all_a_follows_b.user_b_id AS user_b_id;

-- for each of these links find the ones where the friend is also high
--   [user_id, pagerank] join [d0_id, user_b_id] => [user_id, pagerank], [d0_id, user_id]
pagerank_join_follow_a_and_b_high = JOIN pagerank BY user_id, follow_a_high BY user_b_id;
--   [user_id, pagerank], [d0_id, user_id] => [d0_id, d1_id]
follow_a_and_b_high = FOREACH pagerank_join_follow_a_and_b_high GENERATE
	follow_a_high.d0_id     AS d0_id,
	follow_a_high.user_b_id AS d1_id;

-- REPEAT for vicey-versy
pagerank_join_follow_b_high = JOIN pagerank BY user_id, all_a_follows_b BY user_b_id;
follow_b_high               = FOREACH pagerank_join_follow_b_high GENERATE
	all_a_follows_b.user_a_id AS user_a_id
	all_a_follows_b.user_b_id AS d0_id;
pagerank_join_follow_b_and_a_high = JOIN pagerank BY user_id, follow_b_high BY user_a_id;
follow_b_and_a_high = FOREACH pagerank_join_follow_b_and_a_high GENERATE
	follow_b_high.user_a_id AS d1_id;
	follow_a_high.d0_id     AS d0_id;

-- union and distinct to get ALL follows in which BOTH a and b have high pagerank
follow_high = UNION follow_a_and_b_high, follow_b_and_a_high;
distinct_follow_high = DISTINCT follow_high;

--  store
rmf $A_FOLLOWS_B_OUTPUT;
STORE a_follows_b INTO '$A_FOLLOWS_B_OUTPUT'; 
