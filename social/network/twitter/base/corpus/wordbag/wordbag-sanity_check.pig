-- PIG_OPTS='-Dmapred.min.split.size=536870912 -Dio.sort.mb=800 -Dio.sort.record.percent=0.4' pig -p WORDBAG_ROOT=/tmp/wordbag ~/ics/icsdata/social/network/twitter/base/corpus/wordbag/wordbag-sanity_check.pig 
-- hdp-catd /tmp/wordbag-sampled/tok_stats > /mnt/tmp/wordbag/tok_stats-s.tsv
-- cat /mnt/tmp/wordbag/tok_stats-s.tsv  | sort -nk2 |wu-lign
-- for foo in some many lo_disp target_words ; do hdp-catd /tmp/wordbag-sampled/tok_stats-$foo | sort -nk2 | wu-lign > /mnt/tmp/wordbag/tok_stats-$foo.tsv & done

-- user_toks
--   input         6.2B user-toks  403GB

-- tok_stats
--   input:       65M tokens      6.8GB   64 files
--   output:      1000 toks        <1M    64 files   m2.xlarge   < 1 min      

%default WORDBAG_ROOT     '/data/sn/tw/fixd/wordbag';
%default TARGET_WORDS     '(smh|the|lol|mrflip|infochimps|texas|austin|thedatachef|hapax|legomenon|hapax.*legomenon|hadoop|data|your|mom|pinged|cahoots|los|salut|ri{0,5}ght|urinating|archivist|lawsuit|tort|socage|pig|twitter|blog|church|cogroup|tcot|underpants|pajamas|pyjamas|syzygy|zeugma|mook|welder)';
%default TARGET_IDS       '(82363|428333|813286|1554031|4641021|7040932|9721652|14075928|14400690|15094396|15131310|15748351|16061930|16134540|17461978|18359437|19038529|19041500|21230911|44951059|87197143|115485051|116485573|119064111|120845920|138317592)';

REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;

user_tok_user_stats     = LOAD  '$WORDBAG_ROOT/user_tok_user_stats'    AS (tok:chararray, uid:long, num_user_tok_usages:long, tot_user_usages:long, user_tok_freq:double, user_tok_freq_sq:double, vocab:long);
tok_stats               = LOAD  '$WORDBAG_ROOT/tok_stats'              AS (tok:chararray, tot_tok_usages:long, range:long, tok_freq_avg:double,  tok_freq_stdev:double, dispersion:double, tok_freq_ppb:double);
typical_token_stats     = LOAD  '$WORDBAG_ROOT/typical_token_stats'    AS (tok:chararray, c_tok:double, u_tok:double);
tok_stats_many          = LOAD     '$WORDBAG_ROOT-sampled/tok_stats-many' AS (tok:chararray, tot_tok_usages:long, range:long, tok_freq_avg:double,  tok_freq_stdev:double, dispersion:double, tok_freq_ppb:double);

-- many: 418,531 recs 41MB 2 mins

tok_stats_some          = FILTER tok_stats BY ((tot_tok_usages >= 40000L) OR (tot_tok_usages % 1000 == 59));
tok_stats_many          = FILTER tok_stats BY ((tot_tok_usages >= 200L)   AND (dispersion > 0.5));
tok_stats_lo_disp       = FILTER tok_stats BY ((dispersion      < 0.9)    AND (tot_tok_usages >= 5000L));
tok_stats_target_words  = FILTER tok_stats BY tok MATCHES '$TARGET_WORDS';

-- rmf                                $WORDBAG_ROOT-sampled/tok_stats-some
-- STORE tok_stats_some      INTO    '$WORDBAG_ROOT-sampled/tok_stats-some';
-- rmf                                $WORDBAG_ROOT-sampled/tok_stats-many
-- STORE tok_stats_many      INTO    '$WORDBAG_ROOT-sampled/tok_stats-many';
-- rmf                                $WORDBAG_ROOT-sampled/tok_stats-lo_disp
-- STORE tok_stats_some      INTO    '$WORDBAG_ROOT-sampled/tok_stats-lo_disp';
-- rmf                                $WORDBAG_ROOT-sampled/tok_stats-target_words
-- STORE tok_stats_target_words INTO '$WORDBAG_ROOT-sampled/tok_stats-target_words';

user_toks_many  = FILTER user_tok_user_stats
  BY (tok            MATCHES '')
  OR ((chararray)uid MATCHES '$TARGET_IDS')
  OR (uid % 100L == 31)
  ;

-- 20mins when run accidentally off the full dataset for the user regex

rmf                                $WORDBAG_ROOT-sampled/user_toks-many
STORE user_toks_many      INTO    '$WORDBAG_ROOT-sampled/user_toks-many';
user_toks_many          = LOAD    '$WORDBAG_ROOT-sampled/user_toks-many'    AS (tok:chararray, uid:long, num_user_tok_usages:long, tot_user_usages:long, user_tok_freq:double, user_tok_freq_sq:double, vocab:long);

SPLIT user_toks_many INTO
  user_toks_target_words  IF (tok            MATCHES '$TARGET_WORDS'),
  user_toks_target_users  IF ((chararray)uid MATCHES '$TARGET_IDS'),
  user_toks_some          IF (uid % 10000L == 4031)
  ;

-- rmf                                $WORDBAG_ROOT-sampled/user_toks-target_words
-- STORE user_toks_target_words INTO '$WORDBAG_ROOT-sampled/user_toks-target_words';
-- rmf                                $WORDBAG_ROOT-sampled/user_toks-target_users
-- STORE user_toks_target_users INTO '$WORDBAG_ROOT-sampled/user_toks-target_users';
-- rmf                                $WORDBAG_ROOT-sampled/user_toks-some
-- STORE user_toks_some      INTO    '$WORDBAG_ROOT-sampled/user_toks-some';
-- rmf                                $WORDBAG_ROOT-sampled/user_toks-many
-- STORE user_toks_many      INTO    '$WORDBAG_ROOT-sampled/user_toks-many';
-- rmf                                $WORDBAG_ROOT-sampled/user_toks-lo_disp
-- STORE user_toks_some      INTO    '$WORDBAG_ROOT-sampled/user_toks-lo_disp';



