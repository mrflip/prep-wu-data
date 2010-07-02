%default GEO   '/data/sn/tw/fixd/objects/geo'
%default TABLE '/data/sn/tw/fixd/users_table'        
%default FIXD  '/data/sn/tw/fixd/objects/geo-rectified'

geo_objects  = LOAD '$GEO' AS (rsrc:chararray, twid:long, uid:long, sn:chararray, crat:long, lat:float, lon:float, place_id:chararray);
mapping      = LOAD '$TABLE'  AS (sn:chararray, uid:long, sid:long);

-- immediately separate good objects and bad objects
good_objects = FILTER geo_objects BY uid IS NOT NULL;
bad_objects  = FILTER geo_objects BY uid IS NULL;

-- rectify bad objects
joined      = JOIN geo_objects BY sn, mapping BY sn;
filtered    = FILTER joined BY mapping::uid IS NOT NULL;
rectified   = FOREACH filtered GENERATE
                  geo_objects::rsrc     AS rsrc,
                  geo_objects::twid     AS twid,
                  mapping::uid          AS uid,
                  geo_objects::sn       AS sn,
                  geo_objects::crat     AS crat,
                  geo_objects::lat      AS lat,
                  geo_objects::lon      AS lon,
                  geo_objects::place_id AS place_id
              ;
out         = UNION good_objects, rectified;

rmf $FIXD;
STORE out INTO '$FIXD';
