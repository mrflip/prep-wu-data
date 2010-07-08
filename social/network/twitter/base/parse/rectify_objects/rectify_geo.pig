%default GEO   '/data/sn/tw/fixd/objects/geo'
%default TABLE '/data/sn/tw/fixd/users_table'        
%default FIXD  '/data/sn/tw/fixd/objects/geo-rectified'

geo_objects  = LOAD '$GEO' AS (rsrc:chararray, twid:long, uid:long, sn:chararray, crat:long, lat:float, lon:float, place_id:chararray);
mapping      = LOAD '$TABLE'  AS (sn:chararray, uid:long, sid:long);

-- immediately separate good objects and bad objects
SPLIT geo_objects INTO good_objects IF uid IS NOT NULL, bad_objects IF uid IS NULL;

-- rectify bad objects
joined      = JOIN bad_objects BY sn, mapping BY sn;
filtered    = FILTER joined BY mapping::uid IS NOT NULL; --throwing away what didn't rectify
rectified   = FOREACH filtered GENERATE
                  bad_objects::rsrc     AS rsrc,
                  bad_objects::twid     AS twid,
                  mapping::uid          AS uid,
                  bad_objects::sn       AS sn,
                  bad_objects::crat     AS crat,
                  bad_objects::lat      AS lat,
                  bad_objects::lon      AS lon,
                  bad_objects::place_id AS place_id
              ;
out         = UNION good_objects, rectified;

rmf $FIXD;
STORE out INTO '$FIXD';
