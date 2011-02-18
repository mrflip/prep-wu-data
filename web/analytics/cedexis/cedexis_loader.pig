--
-- Load Cedexis data using pig and HBase Dynamic Family Loader
--
register '/home/travis/dev/HbaseBulkloader/build/hbase_bulkloader.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';

%default DATA  '/tmp/streamed/cedexis/'
%default TABLE 'web_anal_cedexis'

data = LOAD '$DATA' AS (row_key:chararray, col_fam:chararray, col_name:chararray, col_val:chararray, date:long);
STORE data INTO '$TABLE' USING com.infochimps.hbase.pig.DynamicFamilyStorage();
