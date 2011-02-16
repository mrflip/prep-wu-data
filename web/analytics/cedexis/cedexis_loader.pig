--
-- Load Cedexis data using pig and HBase TableOutputFormat
--
register '/home/travis/dev/HbaseBulkloader/build/hbase_bulkloader.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';

%default DATA  '/tmp/streamed/cedexis'
%default TABLE 'web_anal_cedexis'
%default CF    'info'

data       = LOAD '$DATA' AS (date:chararray, market_id:chararray, market_label:chararray, country_id:chararray, country_label:chararray, net_id:chararray, network_label:chararray, provider_id:chararray, provider_label:chararray, probe_id:chararray, probe_label:chararray, count:chararray, score:chararray);
cut_fields = FOREACH data GENERATE net_id AS key, net_id AS network_id, date, market_id, market_label, country_id, country_label, network_label, provider_id, provider_label, probe_id, probe_label, count, score; 
STORE cut_fields INTO '$TABLE' USING com.infochimps.hbase.pig.HBaseStorage('$CF:network_id $CF:date $CF:market_id $CF:market_label $CF:country_id $CF:country_label $CF:network_label $CF:provider_id $CF:provider_label $CF:probe_id $CF:probe_label $CF:count $CF:score');

