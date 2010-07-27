--
-- Here we join against mapping table to pull out follower counts. Generate
-- a flat table consisting of followers vs scaled rank.
--
REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;


user_id  = LOAD '$IDS'  AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long, sid:long, isfull:int, health:chararray);       
fullrank = LOAD '$RANK' AS (uid:long, pr:float, list:chararray); -- load everything

rank     = FOREACH fullrank GENERATE uid, pr;                    -- trim list off
mapping  = FOREACH user_id  GENERATE uid, followers;             -- keep followers around for %-ile ranking
distinct_mapping = DISTINCT mapping;        -- hackety hack hack hack
joined   = JOIN rank BY uid, distinct_mapping BY uid; 
flat     = FOREACH joined GENERATE
               rank::uid          AS uid,
               distinct_mapping::followers AS followers,
               rank::pr           AS pr
           ;

grouped  = GROUP flat ALL;
intermed = FOREACH grouped GENERATE FLATTEN(flat), MAX(flat.pr) AS max_pr;
out      = FOREACH intermed
           {
               -- scale rank to range from [0..10]
               scaled = 10.0*( (float)org.apache.pig.piggybank.evaluation.math.LOG(flat::pr + 1.0) / (float)org.apache.pig.piggybank.evaluation.math.LOG(max_pr + 1.0) );
               GENERATE
                   flat::uid       AS uid,
                   flat::followers AS followers,
                   scaled          AS scaled
               ;
           };

rmf $TRSTME;
STORE out INTO '$TRSTME';
