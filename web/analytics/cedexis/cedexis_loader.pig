--
-- Load Cedexis data using pig and HBase Dynamic Family Loader
-- date needs to be formatted to Unix Epoch Time to load into Hbase
--
register '/home/travis/dev/HbaseBulkloader/build/hbase_bulkloader.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';
register '/home/travis/dev/HbaseBulkloader/lib/joda-time-1.6.2.jar';

%default DATA  '/tmp/streamed/cedexis/'
%default TABLE 'web_anal_cedexis'

DEFINE CONVERT com.infochimps.hadoop.pig.datetime.StringFormatToUnix();

data = LOAD '$DATA' AS (row_key:chararray, col_fam:chararray, col_name:chararray, col_val:chararray, date:chararray);
formatted_data = FOREACH data GENERATE row_key, col_fam, col_name, col_val, CONVERT(date);
STORE formatted_data INTO '$TABLE' USING com.infochimps.hbase.pig.DynamicFamilyStorage();
