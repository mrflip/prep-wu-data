--
-- Some of the relationships have timestamps. Need to cut out those fields and distinct whats remaining. This can change later.
--
edge  = LOAD '$EDGE' AS (rsrc:chararray, node_a:chararray, node_b:chararray); -- there will obviously be extra fields, we don't care right now
cut_edge = FOREACH edge GENERATE rsrc, node_a, node_b;
filtered = FILTER cut_edge BY node_a != node_b;
uniqd = DISTINCT filtered;

rmf $UNIQ;
STORE uniqd INTO '$UNIQ';
 
