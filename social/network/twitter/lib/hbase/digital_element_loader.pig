--
-- Load Digital Element data using pig and HBase TableOutputFormat
--
register '/home/travis/dev/HbaseBulkloader/build/hbase_bulkloader.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';

%default DATA  '/tmp/data/web/analytics/digital_element/fixd'
%default TABLE 'web_anal_digital_element'

data     = LOAD '$DATA' AS (row_key:chararray, column_family:chararray, column_name:chararray, column_value:chararray);
STORE data INTO '$TABLE' USING com.infochimps.hbase.pig.DynamicFamilyStorage();
