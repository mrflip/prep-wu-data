%default MATCHED  '/data/sn/tw/fixd/objects/twitter_user_id_matched'
%default PAGERANK '/data/sn/tw/pagerank/a_replies_b_pagerank/pagerank_only'
%default OUT      '/data/sn/tw/pagerank/a_replies_b_pagerank/pagerank_with_profile'
        
matched_ids = LOAD '$MATCHED' AS
              (
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

rank = LOAD '$PAGERANK' AS
       (
         user_id: long,
         pr:      float
       );

joined    = JOIN rank BY user_id, matched_id BY id;
flattened = FOREACH joined GENERATE
                             matched_ids::screen_name     AS screen_name,
                             matched_ids::id              AS user_id,
                             rank::pr                     AS pr,  
                             matched_ids::followers_count AS followers_count,
                             (((double) matched_ids::followers_count)/((double) matched_ids::friends_count)) AS ratio,
                             matched_ids::friends_count   AS friends_count,
                             matched_ids::statuses_count  AS statuses_count,
                             matched_ids::created_at      AS created_at
                           ;

rmf                      $OUT;
STORE OutputTweets INTO '$OUT';
