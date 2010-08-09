-- params (override or leave as default)


REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;

%default TRSTME  '/data/sn/tw/fixd/pagerank/a_follows_b_with_sn'
%default ORDERED '/data/sn/tw/fixd/pagerank/a_follows_b_ordered'

trstme  = LOAD '$TRSTME' AS (sn:chararray, uid:long, pr:float, tq:int);
ordered = ORDER trstme BY pr DESC;

rmf $ORDERED;
STORE ordered INTO '$ORDERED';
