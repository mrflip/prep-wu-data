--
-- Load IP Geo Census data using pig and HBase TableOutputFormat
--
register '/home/travis/dev/HbaseBulkloader/build/hbase_bulkloader.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';

%default DATA  '/tmp/data/demograhics/census/fixd'
%default TABLE 'ip_geo_census'

data     = LOAD '$DATA' AS (row_key:chararray, column_family:chararray, column_name:chararray, column_value:chararray);
STORE data INTO '$TABLE' USING com.infochimps.hbase.pig.DynamicFamilyStorage();
