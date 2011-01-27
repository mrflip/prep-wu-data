register /usr/local/share/pig/contrib/piggybank/java/piggybank.jar

data      = LOAD '$RELS' AS (rsrc:chararray, user_a_id:long, user_b_id:long, rel_type:chararray, twid:long, crat:long, user_b_sn:chararray, in_reply_to_twid:long);
-- for_hbase = STREAM data THROUGH `/home/jacob/Programming/infochimps-data/social/network/twitter/lib/hbase/prepare_relationships.rb --map` AS (row_key:chararray, cf_name:chararray, qualifier:chararray, col_value:chararray); 
-- STORE for_hbase INTO '$OUT' USING org.apache.pig.piggybank.storage.MultiStorage('$OUT', '1', 'none', '\\t');
STORE data INTO '$OUT';
