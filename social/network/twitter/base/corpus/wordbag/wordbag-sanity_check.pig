-- PIG_OPTS='-Dmapred.min.split.size=536870912 -Dio.sort.mb=800 -Dio.sort.record.percent=0.4' pig -p WORDBAG_ROOT=/tmp/wordbag ~/ics/icsdata/social/network/twitter/base/corpus/wordbag/wordbag-sanity_check.pig 
-- hdp-catd /tmp/wordbag-sampled/tok_stats > /mnt/tmp/wordbag/tok_stats-s.tsv
-- cat /mnt/tmp/wordbag/tok_stats-s.tsv  | sort -nk2 |wu-lign
-- for foo in some target_words lo_disp      ; do hdp-catd /tmp/wordbag-sampled/tok_stats-$foo | sort -nk2 | wu-lign > /mnt/tmp/wordbag/tok_stats-$foo.tsv & done
-- for foo in some target_words target_users ; do hdp-catd /tmp/wordbag-sampled/user_toks-$foo | sort -nk2 | wu-lign > /mnt/tmp/wordbag/user_toks-$foo.tsv & done

-- user_toks      32mins      6.2B recs 433GB   =>  115M recs 7.8GB | 832 mappers 40 m2.xl
-- tok_stats      <2min        65M toks   7GB       420k recs  41MB 

-- ===========================================================================
-- 
-- Filters to run
--

%default WORDBAG_ROOT     '/data/sn/tw/fixd/wordbag';
%default TARGET_WORDS     '(smh|the|lol|mrflip|infochimps|texas|austin|thedatachef|hapax|legomenon|hapax.*legomenon|hadoop|data|your|mom|pinged|cahoots|los|salut|ri{0,5}ght|urinating|archivist|lawsuit|tort|socage|pig|twitter|blog|church|cogroup|tcot|underpants|pajamas|pyjamas|syzygy|zeugma|mook|welder)';
%default TARGET_IDS       '(82363|428333|813286|1554031|4641021|7040932|9721652|14075928|14400690|15094396|15131310|15748351|16061930|16134540|17461978|18359437|19038529|19041500|21230911|44951059|87197143|115485051|116485573|119064111|120845920|138317592)';

-- ===========================================================================
-- 
-- Default Loads
--
-- user_tok_user_stats     = LOAD  '$WORDBAG_ROOT/user_tok_user_stats'    AS (tok:chararray, uid:long, num_user_tok_usages:long, tot_user_usages:long, user_tok_freq:double, user_tok_freq_sq:double, vocab:long);
-- tok_stats               = LOAD  '$WORDBAG_ROOT/tok_stats'              AS (tok:chararray, tot_tok_usages:long, range:long, tok_freq_avg:double,  tok_freq_stdev:double, dispersion:double, tok_freq_ppb:double);
-- typical_token_stats     = LOAD  '$WORDBAG_ROOT/typical_token_stats'    AS (tok:chararray, c_tok:double, u_tok:double);
REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;

-- ===========================================================================
-- 
-- Sample: user_toks
--

-- user_toks_many  = FILTER user_tok_user_stats
--   BY (tok            MATCHES '')
--   OR ((chararray)uid MATCHES '$TARGET_IDS')
--   OR (uid % 100L == 31)
--   ;
-- rmf                                $WORDBAG_ROOT-sampled/user_toks-many
-- STORE user_toks_many      INTO    '$WORDBAG_ROOT-sampled/user_toks-many';

SPLIT user_toks_many INTO
  user_toks_target_words  IF (tok            MATCHES '$TARGET_WORDS'),
  user_toks_target_users  IF ((chararray)uid MATCHES '$TARGET_IDS'),
  user_toks_some          IF (uid % 10000L == 4031)
  ;
-- re/uncomment the above and below for first time vs. repeated use
user_toks_many          = LOAD    '$WORDBAG_ROOT-sampled/user_toks-many'    AS (tok:chararray, uid:long, num_user_tok_usages:long, tot_user_usages:long, user_tok_freq:double, user_tok_freq_sq:double, vocab:long);

-- rmf                                $WORDBAG_ROOT-sampled/user_toks-target_words
-- STORE user_toks_target_words INTO '$WORDBAG_ROOT-sampled/user_toks-target_words';
-- rmf                                $WORDBAG_ROOT-sampled/user_toks-target_users
-- STORE user_toks_target_users INTO '$WORDBAG_ROOT-sampled/user_toks-target_users';
-- rmf                                $WORDBAG_ROOT-sampled/user_toks-some
-- STORE user_toks_some         INTO '$WORDBAG_ROOT-sampled/user_toks-some';
user_toks_target_words     = LOAD '$WORDBAG_ROOT-sampled/user_toks-target_words'    AS (tok:chararray, uid:long, num_user_tok_usages:long, tot_user_usages:long, user_tok_freq:double, user_tok_freq_sq:double, vocab:long);
user_toks_target_users     = LOAD '$WORDBAG_ROOT-sampled/user_toks-target_users'    AS (tok:chararray, uid:long, num_user_tok_usages:long, tot_user_usages:long, user_tok_freq:double, user_tok_freq_sq:double, vocab:long);
user_toks_some             = LOAD '$WORDBAG_ROOT-sampled/user_toks-some'            AS (tok:chararray, uid:long, num_user_tok_usages:long, tot_user_usages:long, user_tok_freq:double, user_tok_freq_sq:double, vocab:long);

user_words_g = GROUP user_toks_target_users BY uid;
user_words_0 = FOREACH user_words_g GENERATE
  group AS uid, 
  MAX(num_user_tok_usages), MAX(tot_user_usages),
  MAX(user_tok_freq),       MAX(user_tok_freq_sq), MAX(vocab),
  user_toks_target_users.tok AS toks
  ;
rmf                                $WORDBAG_ROOT-sampled/user_words
STORE user_toks_some         INTO '$WORDBAG_ROOT-sampled/user_words';

-- ===========================================================================
-- 
-- Sample: tok_stats
--

-- tok_stats_many          = FILTER tok_stats      BY ((tot_tok_usages >= 200L)   AND (dispersion > 0.5));
-- rmf                                $WORDBAG_ROOT-sampled/tok_stats-many
-- STORE tok_stats_many      INTO    '$WORDBAG_ROOT-sampled/tok_stats-many';
-- tok_stats_many          = LOAD    '$WORDBAG_ROOT-sampled/tok_stats-many' AS (tok:chararray, tot_tok_usages:long, range:long, tok_freq_avg:double,  tok_freq_stdev:double, dispersion:double, tok_freq_ppb:double);

-- subsamples

-- tok_stats_some          = FILTER tok_stats-many BY ((tot_tok_usages >= 40000L) OR (tot_tok_usages % 1000 == 59));
-- tok_stats_lo_disp       = FILTER tok_stats-many BY ((tot_tok_usages >= 5000L)  AND (dispersion < 0.9));
-- tok_stats_target_words  = FILTER tok_stats-many BY tok MATCHES '$TARGET_WORDS';

-- rmf                                $WORDBAG_ROOT-sampled/tok_stats-some
-- STORE tok_stats_some      INTO    '$WORDBAG_ROOT-sampled/tok_stats-some';
-- rmf                                $WORDBAG_ROOT-sampled/tok_stats-lo_disp
-- STORE tok_stats_some      INTO    '$WORDBAG_ROOT-sampled/tok_stats-lo_disp';
-- rmf                                $WORDBAG_ROOT-sampled/tok_stats-target_words
-- STORE tok_stats_target_words INTO '$WORDBAG_ROOT-sampled/tok_stats-target_words';



