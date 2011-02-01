--
-- Table loader for AFollowsB
-- Currently not in use...
--
register '/home/travis/HbaseBulkloader/build/hbase_bulkloader.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';
register '/usr/local/share/pig/build/pig-0.8.0-SNAPSHOT-core.jar';

%default TABLE 'soc_net_tw_a_rel_b'
%default PREPARE_SCRIPT '/home/travis/infochimps-data/social/network/twitter/lib/hbase/prepare_a_follows_b.rb'

data      = LOAD '$DATA' AS (rsrc:chararray, user_a_id:long, user_b_id:long);
prep_data = STREAM data THROUGH `$PREPARE_SCRIPT --map` AS (row_key:chararray, col_name:chararray, col_val:chararray);
STORE prep_data INTO '$TABLE' USING com.infochimps.hbase.pig.HBaseStorage('follow:row_key follow:col_name follow:col_val');
