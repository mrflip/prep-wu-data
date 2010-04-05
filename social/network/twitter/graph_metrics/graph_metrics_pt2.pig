
%default  REDUCERS 18
%default  MULTI_EDGE_AND_USER_FILE 'fixd/tw/graph/multi_edge_and_user'

MultiEdge               = LOAD    'fixd/tw/graph/multi_graph' AS (
  rsrc: chararray, src: long, dest: long,
  fo_out: long, fo_in: long,
  re_out: long, re_in: long,
  at_out: long, at_in: long,
  rt_out: long, rt_in: long,
  fv_out: long, fv_in: long
  );

TwitterUserId = LOAD 'fixd/tw/meta/twitter_user_id_matched' AS (
  rsrc:             chararray,
  id:               long,
  scraped_at:       long,
  screen_name:      chararray,
  protected:        int,
  followers_count:  long,
  friends_count:    long,
  statuses_count:   long,
  favourites_count: long,
  created_at:       chararray,
  sid:              long,
  is_full:          long,
  health:           chararray
);

MultiEdgeAndUser_0 = JOIN
  TwitterUserId BY id   RIGHT OUTER,
  MultiEdge     BY dest
  PARALLEL $REDUCERS
  ;

MultiEdgeAndUser_1 = FOREACH MultiEdgeAndUser_0 GENERATE
  MultiEdge::rsrc,
  src                   AS src:long,
  dest                  AS dest:long,
  (fo_out > 0L ? 1L : 0L) AS fo_out: long,
  (fo_in  > 0L ? 1L : 0L) AS fo_in:  long,
  --
  re_out                AS re_out:long,
  re_in                 AS re_in:long,
  --
  at_out                AS at_out:long,
  at_in                 AS at_in:long,
  (at_out > 0L ? 1L : 0L) AS at_out_with: long,
  (at_in  > 0L ? 1L : 0L) AS at_in_with:  long,
  --
  rt_out                AS rt_out:long,
  rt_in                 AS rt_in:long,
  (rt_out > 0L ? 1L : 0L) AS rt_out_with: long,
  (rt_in  > 0L ? 1L : 0L) AS rt_in_with:  long,
  --
  fv_out                AS fv_out:long,
  fv_in                 AS fv_in:long ,
  (fv_out > 0L ? 1L : 0L) AS fv_out_with: long,
  (fv_in  > 0L ? 1L : 0L) AS fv_in_with:  long,
  ((at_out > 0L) OR (rt_out > 0L) OR (fv_out > 0L) ? 1L : 0L) AS any_out_with:long,
  ((at_in  > 0L) OR (rt_in  > 0L) OR (fv_in  > 0L) ? 1L : 0L) AS any_in_with:long,
  ((fo_out > 0L) OR (at_out > 0L) OR (rt_out > 0L) OR (fv_out > 0L) ? 1L : 0L) AS all_out_with:long,
  ((fo_in  > 0L) OR (at_in  > 0L) OR (rt_in  > 0L) OR (fv_in  > 0L) ? 1L : 0L) AS all_in_with:long,
  scraped_at,
  screen_name,
  protected,
  followers_count,
  friends_count,
  statuses_count,
  favourites_count,
  created_at,
  sid
  ;
DESCRIBE MultiEdgeAndUser_1;

-- MultiEdgeAndUser_2 = ORDER MultiEdgeAndUser_1 BY 


rmf                            $MULTI_EDGE_AND_USER_FILE ;
STORE MultiEdgeAndUser_1 INTO '$MULTI_EDGE_AND_USER_FILE';
