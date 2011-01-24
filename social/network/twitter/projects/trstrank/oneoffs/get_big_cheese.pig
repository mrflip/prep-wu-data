-- params (override or leave as default)

%default TRSTME  '/tmp/trstrank'
%default ORDERED '/tmp/trstrank_ordered'

trstme  = LOAD '$TRSTME' AS (sn:chararray, uid:long, pr:float, tq:int);
ordered = ORDER trstme BY pr DESC;

STORE ordered INTO '$ORDERED';
