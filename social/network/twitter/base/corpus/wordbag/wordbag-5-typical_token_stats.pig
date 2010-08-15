
--  num_toks,   sum_freq_ppb,           sum_freq_ppb_sq,        avg_freq_ppb,           avg_freq_ppb_sq,        std_freq_ppb,           u_tok,                  c_tok
--  65524511 	9.99999999991002E8	1.8154320245688395E15	15.261464522657818	2.7706151436503503E7	5263.641184978715	15.261464522657818	549.8376947117983
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

-- Perform a bayesian estimate of the frequency (u_tok_ppb) and spread (c_tok_ppb)

tok_stats_fg  = FOREACH tok_stats GENERATE tok, tot_tok_usages;
tok_stats_rg  = FOREACH tok_stats_fg
  {
  c_tok = (double)$C_PRIOR + (double)$TOT_USAGES; -- c_1 = Total_usages ; avg_freq
  u_tok = (
    ((double)$C_PRIOR * (double)$U_PRIOR + (double)tot_tok_usages) /
    ((double)$C_PRIOR                    + (double)$TOT_USAGES)   );

  --
  --
  --  c  = u (1-u) / (std * std)  - 1
  --     = u       / sd**2
  --     = 1e9 ( u_ppb / (sd_ppb**2) )  => 1e9 ( 15 / 5263**2 ) = 1000e9 / 28e6 = 550
  -- 

  
  --
  -- observed 65 million tokens
  -- prior expectation is they all have the same frequency: 16.5B / 65M = 253 usages / token, 15.26 ppb
  -- so
  -- u_0 =  15.26 ppb
  -- c_0 = 541.53 
  -- n_0 = 65M
  
  -- c_x = c_0 + n_x
  -- u_x = (u_0      + s_1 / c_0) / ( 1 + n_1 / c_0)
  --
  -- u_x = ( u_0 * c0 + s_1 ) / ( c0 + n_1 )
  --
  -- if n >> c0,
  --     = ((u_0 * c0/n) + (s_1/n)) / (c0/n + 1)
  --     = f_1 + (u_0 * c_0 / n)
  --
  --
  -- c_1 = 65M + 541 = 65M
  --
  --
  -- u_1 = (  u_0 *  c0  + s_1   ) / (c0 + n_1)
  -- 
  --
  -- u_2 = c_1*u_1 + s_2  / (c_1 + n_2)
  --
  -- c_2 = c_1 + n_2
  --
  -- u_2 = ((16B * s_1 / 16B) + s_2) / (
  --
  -- c_1 = ( u_0    * (1 - u_0) ) /
  --     = ( 15                 ) / (2/100) ) - 1 = 
  --
  -- if c_prior = n_observations / 2
  -- 

  -- c0 16B / 2
  -- u0 15.261464522657818
  --
  -- c1_pajamas    => 2 * 16B
  -- u1_pajamas    => ( 16B * 15 / 1B + 6000 ) / ( 2 * 16B ) =>
  --               => ( 250           + 6000 ) / ( 2 * 16B ) => 6000 / (2 * 16B)
  --
  --                                                         => f   / 2
  -- u1_glorpnik   => ( 15 / 2 )                             => u_0 / 2
  --
  -- n         = 1_000              
  -- s_pajamas =     3  => 3_000_000
  --
  -- 16B * 6000 / 1e9 + 3
  -- 16B              + 1000  
  
  GENERATE
    tok                         AS tok,
    (double)tok_freq_ppb        AS tok_freq_ppb:   double,  -- total times THIS tok has been spoken out of the total toks that have EVER been spoken
    COUNT(user_tok_user_stats)  AS range:          long,    -- total number of people who spoke this tok at least once
    (double)tok_freq_stdev      AS tok_freq_stdev: double,  -- standard deviation of the frequencies at which this tok is spoken
    (double)dispersion          AS dispersion:     double,  -- dispersion (see above)
    (double)u_tok_ppb           AS u_tok_ppb:      double,  -- posterior est. of token frequency, ppb
    (double)c_tok_ppb           AS c_tok_ppb:      double   -- posterior est. of token spread, ppb
    ;
};

rmf                     $WORDBAG_ROOT/typical_token_stats
STORE tok_stats_rg INTO '$WORDBAG_ROOT/token_stats_regressed';
tok_stats_rg     = LOAD '$WORDBAG_ROOT/token_stats_regressed' AS (tok:chararray, c_tok:double, u_tok:double);
