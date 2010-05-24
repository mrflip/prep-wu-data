REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar ;

%default USER_WORDBAG    '/data/sn/tw/fixd/word/user_word_bag_with_stats'; --input location
%default SAMPLED_WORDBAG '/tmp/sampled_user_word_bag_with_stats';                  --output location

UserTokStats = LOAD '$USER_WORDBAG' AS
               (
                        tok:                 chararray,
                        user_id:             chararray, --could be screen name OR long id
                        num_user_tok_usages: long,
                        tot_user_usages:     long,
                        user_tok_freq_ppb:   float,
                        vocab:               long,
                        tot_tok_usages:      long,
                        range:               float,
                        user_freq_avg:       float,
                        user_freq_stdev:     float,
                        global_freq_avg:     float,
                        global_freq_stdev:   float,
                        dispersion:          float,
                        tok_freq_ppb:        float
               );


SampledUserTokStats = FILTER UserTokStats BY org.apache.pig.piggybank.evaluation.string.UPPER(user_id) MATCHES '^(MRFLIP|1554031|INFOCHIMPS|15748351|SILONA|82363|BARACKOBAMA|813286|THE_REAL_SHAQ|17461978|RWW|4641021|WHOLEFOODS|15131310|ZAPPOS|7040932|CHEAPTWEETS|18359437|JESSECROUCH|9721652|DONCARLO|15094396|DHRUVBANSAL|19038529|JOSEPHKELLY|14400690|REALSHERIFFJOE|44951059|XBIEBERPASSION|120845920|ADAMTRUSSELL|138317592|AUSTINONRAILS|15875986|LSRC|14221735|SWINGLY|7579122|CLOUDERA|16134540|KLOUT|15134782|WORDNIK|15863767|CADMUS|8789732|80LEGS|27186158|SHITMYDADSAYS|62581962)';

rmf                      $SAMPLED_WORDBAG;
STORE SampledUserTokStats INTO '$SAMPLED_WORDBAG';

