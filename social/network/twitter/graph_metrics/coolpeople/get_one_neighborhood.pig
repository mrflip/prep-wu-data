%default AFOLLOWSB '/data/sn/tw/fixd/objects/a_follows_b'
%default USER      '15748351'; --infochimps
%default HOOD      '/data/sn/tw/cool/infochimps_hood';


AdjList = LOAD '$AFOLLOWSB' AS (
                  rsrc:                 chararray,
                  user_a_id:            long,
                  user_b_id:            long
             );

-- get followers and followees of USER
Out1  = FILTER AdjList BY user_a_id MATCHES '$USER'; -- USER --> Out1
In1   = FILTER AdjList BY user_b_id MATCHES '$USER'; -- USER <-- In1

-- get followers and followees of 1 neighborhood
Out2 = JOIN AdjList BY user_a_id, Out1 BY user_b_id; -- Out1 --> Out2
In2  = JOIN AdjList BY user_a_id, In1  By user_a_id;
