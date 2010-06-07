-- libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- defaults
%default A_REP_B  '/data/sn/tw/fixd/objects/a_replies_b'
%default OUT_A '/data/sn/tw/fixd/infl_metrics/reply_out_counts'
%default OUT_B '/data/sn/tw/fixd/infl_metrics/reply_in_counts'

-- load a_replies_b data
ARepliesB = LOAD '$A_REP_B' AS (rsrc:chararray,
                                a_id:long,
                                b_id:long,
                                tw_id:long,
                                rep_tw_id:long);

-- only want the a and b user ids
ARepBIds = FOREACH ARepliesB GENERATE a_id, b_id;

-- group on a id and b id and count each
ARepliesGroup = GROUP ARepBIds BY a_id;
ARepliesCount = FOREACH ARepliesGroup GENERATE group, COUNT(ARepBIds);
RepliesToBGroup = GROUP ARepBIds BY b_id;
RepliesToBCount = FOREACH RepliesToBGroup GENERATE group, COUNT(ARepBIds);

rmf $OUT_A; 
STORE ARepliesCount INTO '$OUT_A';
rmf $OUT_B;
STORE RepliesToBCount INTO '$OUT_B';
