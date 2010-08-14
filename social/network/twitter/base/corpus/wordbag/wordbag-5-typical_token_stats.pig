
--  num_toks,   sum_freq_ppb,           sum_freq_ppb_sq,        avg_freq_ppb,           avg_freq_ppb_sq,        std_freq_ppb,           u_tok,                  c_tok
--  65524511	9.99999999991002E8	1.8154320245688395E15	15.261464522657818	2.7706151436503503E7	5263.641184978715	15.261464522657818	549.8376947117983
--
-- Usage:
-- PIG_OPTS='-Dio.sort.record.percent=0.2' pig -p WORDBAG_ROOT=/tmp/wordbag ~/ics/icsdata/social/network/twitter/base/corpus/wordbag/wordbag-4-tot_tok_stats.pig
--

%default WORDBAG_ROOT     '/data/sn/tw/fixd/wordbag';

-- values found from one off job to determine "typical token", see notes
%default C_PRIOR          '549.8376947117983'
%default U_PRIOR          '15.261464522657818'
%default N_USERS          '3.8002003E7';       -- total users in the sample **AS A DOUBLE**
%default SQRT_N_USERS_M1  '6163.576465581395';
%default TOT_USAGES       '1.6501474834E10';   -- total non-distinct usages **AS A DOUBLE**

tok_stats     = LOAD '$WORDBAG_ROOT/tok_stats' AS (tok:chararray, tot_tok_usages:long, range:long, tok_freq_avg:double, tok_freq_stdev:double, dispersion:double, tok_freq_ppb:double);
tok_stats_fg  = FOREACH tok_stats GENERATE tok, tot_tok_usages;
tok_stats_rg  = FOREACH tok_stats_fg
                {
                  c_tok = (double)$C_PRIOR + (double)$TOT_USAGES;
                  u_tok = ((double)$C_PRIOR*(double)$U_PRIOR + (double)tot_tok_usages)/((double)$C_PRIOR + (double)$TOT_USAGES);
                  GENERATE
                    tok   AS tok,
                    c_tok AS c_tok,
                    u_tok AS u_tok
                  ;
                };

rmf                     $WORDBAG_ROOT/typical_token_stats
STORE tok_stats_rg INTO '$WORDBAG_ROOT/token_stats_regressed';
tok_stats_rg     = LOAD '$WORDBAG_ROOT/token_stats_regressed' AS (tok:chararray, c_tok:double, u_tok:double);
