-- params (override or leave as default)


REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;

%default TRSTME  '/data/sn/tw/fixd/pagerank/a_follows_b_with_sn'
%default ORDERED '/data/sn/tw/fixd/pagerank/a_follows_b_ordered'

trstme  = LOAD '$TRSTME' AS (sn:chararray, uid:long, followers:long, raw:float, scaled:float);
cut     = FOREACH trstme GENERATE sn, scaled;
ordered = ORDER cut BY scaled DESC;

rmf $ORDERED;
STORE ordered INTO '$ORDERED';
