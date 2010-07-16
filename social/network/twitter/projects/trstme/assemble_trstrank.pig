REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;

%default IDS    '/data/sn/tw/fixd/objects/twitter_user_id'
%default RANK   '/data/sn/tw/fixd/pagerank/a_follows_b'
%default TRSTME '/data/sn/tw/fixd/pagerank/a_follows_b_with_stats'

user_id  = LOAD '$IDS'  AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long, sid:long, isfull:int, health:chararray);
fullrank = LOAD '$RANK' AS (uid:long, pr:float, list:chararray); -- load everything
rank     = FOREACH fullrank GENERATE uid, pr;                    -- trim list off
mapping  = FOREACH user_id  GENERATE uid, sn, followers;         -- keep followers around for %-ile ranking
joined   = JOIN rank BY uid, mapping BY uid;                     -- doing this as an inner join removes the dummy (no screen name matches it!) 
flat     = FOREACH joined GENERATE
               mapping::sn        AS sn,
               rank::uid          AS uid,
               mapping::followers AS followers,
               rank::pr           AS pr
           ;

grouped  = GROUP flat ALL;
intermed = FOREACH grouped GENERATE FLATTEN(flat), MAX(flat.pr) AS max_pr;
out      = FOREACH intermed
           {
               scaled = 10.0*( (float)org.apache.pig.piggybank.evaluation.math.LOG(flat::pr + 1.0) / (float)org.apache.pig.piggybank.evaluation.math.LOG(max_pr + 1.0) );
               GENERATE
                   flat::sn        AS sn,
                   flat::uid       AS uid,
                   flat::followers AS followers,
                   flat::pr        AS pr,
                   scaled          AS scaled
               ;
           };

rmf $TRSTME;
STORE out INTO '$TRSTME';
