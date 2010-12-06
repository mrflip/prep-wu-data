--
-- Produce a weighted bipartite graph of (user,term,weight)tuples
--
-- word_token	quot	10086755811	87300544	20100306193853
%default TOKS    '/data/terms/tdidf/word_token'
%default BIGRPH  '/data/terms/tdidf/bip_graph'
%default N_USERS 344858l        

REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar;
-- DEFINE LOG 'org.apache.pig.piggybank.evaluation.math.LOG';

word_token = LOAD '$TOKS' AS (rsrc:chararray, term:chararray, tweet_id:long, user_id:long, created_at:long);
terms      = FOREACH word_token GENERATE term, user_id; -- not unique yet
u_terms    = GROUP terms BY (user_id, term);
u_terms_c  = FOREACH u_terms GENERATE FLATTEN(group) AS (user_id, term), COUNT(terms) AS term_freq;
u_terms_f  = FILTER u_terms_c BY term_freq > 1;
terms_g    = GROUP u_terms_f BY term;
terms_fg   = FOREACH terms_g GENERATE FLATTEN(u_terms_f) AS (user_id, term, term_freq), COUNT(u_terms_f) AS doc_freq;
weighted   = FOREACH terms_fg {
               log_term_freq    = org.apache.pig.piggybank.evaluation.math.LOG((float)term_freq);
               log_inv_doc_freq = org.apache.pig.piggybank.evaluation.math.LOG((float)$N_USERS/(float)doc_freq);
               weight           = log_term_freq*log_inv_doc_freq;
               GENERATE user_id, term, weight;
             };

rmf $BIGRPH;
STORE weighted INTO '$BIGRPH';

-- LOAD '$BIGRPH' AS (user_id:long, term:chararray, weight:float);
