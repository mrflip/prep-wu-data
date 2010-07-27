%default TWOUTIN '/data/sn/tw/fixd/graph/tweet_flux'
%default DEGDIST '/data/sn/tw/fixd/graph/degree_distribution'
%default BREAK   '/data/sn/tw/fixd/graph/tweet_flux_breakdown'
%default ATRANK  '/data/sn/tw/fixd/pagerank/a_atsigns_b_with_fo'
%default FORANK  '/data/sn/tw/fixd/pagerank/a_follows_b_with_fo'        
%default IDS     '/data/sn/tw/fixd/objects/twitter_user_id'
%default METRICS '/data/sn/tw/fixd/influencer_metrics'            

ids      = LOAD '$IDS'      AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long, sid:long, isfull:int, health:chararray);        
deg_dist = LOAD '$DEGDIST'  AS (uid:long, fo_o:long, fo_i:long, at_o:long, at_i:long, re_o:long, re_i:long, rt_o:long, rt_i:long);
tw_dist  = LOAD '$TWOUTIN'  AS (uid:long, tw_o:long, tw_i:long);
break_dn = LOAD '$BREAK'    AS (uid:long, ms_tw_o:long, hsh_o:long, sm_o:long, url_o:long); -- measured tw_o
at_rank  = LOAD '$ATRANK'   AS (uid:long, followers:long, rank:float);
fo_rank  = LOAD '$FORANK'   AS (uid:long, followers:long, rank:float);        

cut_at   = FOREACH at_rank GENERATE uid, rank;
cut_fo   = FOREACH fo_rank GENERATE uid, rank;
user_id  = FOREACH ids GENERATE uid, sn, followers, crat;

with_deg = JOIN user_id BY uid FULL OUTER, deg_dist BY uid;
first    = FOREACH with_deg
           {
               uid = ( user_id::uid IS NOT NULL ? user_id::uid : deg_dist::uid );
               GENERATE
                   user_id::sn        AS sn,
                   uid                AS uid,
                   user_id::crat      AS crat,
                   user_id::followers AS followers,
                   deg_dist::fo_o     AS fo_o,
                   deg_dist::fo_i     AS fo_i,
                   deg_dist::at_o     AS at_o,
                   deg_dist::at_i     AS at_i,
                   deg_dist::re_o     AS re_o,
                   deg_dist::re_i     AS re_i,
                   deg_dist::rt_o     AS rt_o,
                   deg_dist::rt_i     AS rt_i
               ;
           };

with_twdist = JOIN first BY uid FULL OUTER, tw_dist BY uid;
second      = FOREACH with_twdist
              {
                  uid = ( first::uid IS NOT NULL ? first::uid : tw_dist::uid );
                  GENERATE
                      first::sn        AS sn,
                      uid              AS uid,
                      first::crat      AS crat,
                      first::followers AS followers,
                      first::fo_o      AS fo_o,
                      first::fo_i      AS fo_i,
                      first::at_o      AS at_o,
                      first::at_i      AS at_i,
                      first::re_o      AS re_o,
                      first::re_i      AS re_i,
                      first::rt_o      AS rt_o,
                      first::rt_i      AS rt_i,
                      tw_dist::tw_o    AS tw_o,
                      tw_dist::tw_i    AS tw_i           
                  ;
              };

with_brk = JOIN second BY uid FULL OUTER, break_dn BY uid;
third    = FOREACH with_brk
           {
               uid = ( second::uid IS NOT NULL ? second::uid : break_dn::uid );
               GENERATE
                   second::sn        AS sn,            
                   uid               AS uid,           
                   second::crat      AS crat,          
                   second::followers AS followers,     
                   second::fo_o      AS fo_o,          
                   second::fo_i      AS fo_i,          
                   second::at_o      AS at_o,          
                   second::at_i      AS at_i,          
                   second::re_o      AS re_o,          
                   second::re_i      AS re_i,          
                   second::rt_o      AS rt_o,          
                   second::rt_i      AS rt_i,          
                   second::tw_o      AS tw_o,          
                   second::tw_i      AS tw_i,
                   break_dn::ms_tw_o AS ms_tw_o,
                   break_dn::hsh_o   AS hsh_o,
                   break_dn::sm_o    AS sm_o,
                   break_dn::url_o   AS url_o          
               ;
           };

with_at = JOIN third BY uid FULL OUTER, cut_at BY uid;
fourth  = FOREACH with_at
          {
              uid = ( third::uid IS NOT NULL ? third::uid : cut_at::uid );
              GENERATE
                  third::sn        AS sn,            
                  uid              AS uid,           
                  third::crat      AS crat,          
                  third::followers AS followers,     
                  third::fo_o      AS fo_o,          
                  third::fo_i      AS fo_i,          
                  third::at_o      AS at_o,          
                  third::at_i      AS at_i,          
                  third::re_o      AS re_o,          
                  third::re_i      AS re_i,          
                  third::rt_o      AS rt_o,          
                  third::rt_i      AS rt_i,          
                  third::tw_o      AS tw_o,          
                  third::tw_i      AS tw_i,          
                  third::ms_tw_o   AS ms_tw_o,       
                  third::hsh_o     AS hsh_o,         
                  third::sm_o      AS sm_o,          
                  third::url_o     AS url_o,
                  cut_at::rank     AS at_tr
              ;
          };

with_fo = JOIN fourth BY uid FULL OUTER, cut_fo BY uid;
flat    = FOREACH with_fo
          {
              uid = ( fourth::uid IS NOT NULL ? fourth::uid : cut_fo::uid );
              GENERATE
                  'influencer'      AS rsrc,
                  fourth::sn        AS sn,            
                  uid               AS uid,           
                  fourth::crat      AS crat,          
                  fourth::followers AS followers,     
                  fourth::fo_o      AS fo_o,          
                  fourth::fo_i      AS fo_i,          
                  fourth::at_o      AS at_o,          
                  fourth::at_i      AS at_i,          
                  fourth::re_o      AS re_o,          
                  fourth::re_i      AS re_i,          
                  fourth::rt_o      AS rt_o,          
                  fourth::rt_i      AS rt_i,          
                  fourth::tw_o      AS tw_o,          
                  fourth::tw_i      AS tw_i,          
                  fourth::ms_tw_o   AS ms_tw_o,       
                  fourth::hsh_o     AS hsh_o,         
                  fourth::sm_o      AS sm_o,          
                  fourth::url_o     AS url_o,
                  fourth::at_tr     AS at_tr,
                  cut_fo::rank      AS fo_tr
              ;
          };
          

out = FILTER flat BY sn != '0';
rmf $METRICS;
STORE out INTO '$METRICS';
