-- Here is an example Pig script used to generate the Example-smiley-counts.tsv dataset.
-- It rolls up by smiley to find the releative frequency of smiley faces across the twitter corpus.

%default TOKENS_BY_MONTH_FILE         'fixd/tw/tokens/tokens_by_month'
%default SMILEYS_COUNT_FILE          'fixd/tw/tokens/smileys_count'
%default REDUCERS    20

TokensByMonth = LOAD '$TOKENS_BY_MONTH_FILE' AS (rsrc:chararray, crat_bin:long, num:long, text:chararray);

SmileysCount_0 = FILTER TokensByMonth BY (rsrc == 'smiley') ;

SmileysCount_1 = GROUP SmileysCount_0 BY text ;
SmileysCount_2 = FOREACH SmileysCount_1 GENERATE
  (long)SUM(SmileysCount_0.num)       AS num:long,
  group          AS text
  ;

SmileysCount_3 = ORDER SmileysCount_2 BY num DESC, text ASC ;

DESCRIBE   SmileysCount_3;
ILLUSTRATE SmileysCount_3;

rmf                         $SMILEYS_COUNT_FILE  ;
STORE SmileysCount_3  INTO '$SMILEYS_COUNT_FILE' ;
SmileysCount3       = LOAD '$SMILEYS_COUNT_FILE' AS (num:long, text:chararray);
