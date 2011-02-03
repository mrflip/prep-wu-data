--
-- Load trstrank using pig and HBase TableOutputFormat
--
register '/home/jacob/Programming/hbase_bulkloader/build/hbase_bulkloader.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';

%default TABLE 'soc_net_tw_trstrank'

data       = LOAD '$DATA' AS (screen_name:chararray, uid:long, rank:float, trst_quotient:int);
cut_fields = FOREACH data GENERATE uid AS key, uid AS user_id, screen_name, rank, trst_quotient;
STORE cut_fields INTO '$TABLE' USING com.infochimps.hbase.pig.HBaseStorage('$TODAY:user_id $TODAY:screen_name $TODAY:rank $TODAY:trst_quotient');
