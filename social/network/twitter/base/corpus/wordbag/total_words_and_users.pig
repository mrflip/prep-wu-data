%default WORDBAG '/data/sn/tw/fixd/word/user_word_bag';

-- load input data
WordBags = LOAD '$WORDBAG' AS
            (
                word:              chararray,
                user_id:           long,
                word_usages:       long,
                user_usages:       long,
                user_word_freq:    float,
                user_word_freq_sq: float,
                vocab:             long
            );

CutFields = FOREACH WordBags GENERATE user_id, user_usages;
Uniqd     = DISTINCT CutFields;
Grouped   = GROUP Uniqd ALL;
Counts    = FOREACH Grouped GENERATE COUNT(Uniqd) AS num_users, SUM(Uniqd.user_usages) AS num_words;
DUMP Counts;
