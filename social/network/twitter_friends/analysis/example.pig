
--
-- Load the relation
--
-- Ex.
--  jerry	costanza81
--  jerry	elainebenes
--  jerry	kramer
--  costanza81	jerry
--  costanza81	elainebenes
--  elainebenes	jerry
--  kramer	lomez
--  kramer	jerry
a_f_b = load 'fakedata/a_follows_b.tsv' using PigStorage('\t') AS (user_a_id, user_b_id, scraped_at);

--
-- One-Neighborhood
--
-- f_1hd
--  jerry	< costanza81, elainebenes, kramer >	< costanza81, elainebenes, kramer >
--  costanza81	< jerry, elainebenes >			< jerry >
--  elainebenes	< jerry >				< jerry, costanza81 >
--  kramer	< jerry, lomez >			< jerry >
--  lomez	< >					< kramer >
--
_f_1hd  	= COGROUP a_f_b BY user_a_id AS og, a_f_b BY user_b_id AS ig 			;
f_1hd		= FOREACH _f_1hd GENERATE og.user_b_id AS outlinks, ig.user_a_id AS inlinks 	;

--
-- Two-Neighborhoods
--
--  jerry	< jerry  	costanza81  	 elainebenes >
--  jerry	< jerry  	costanza81  	 jerry >
--  jerry	< jerry  	elainebenes  	 jerry >
--  jerry	< jerry  	kramer  	 jerry >
--  jerry	< jerry  	kramer  	 lomez >
--  costanza81	< costanza81	jerry   	 costanza81 >
--  costanza81	< costanza81	jerry   	 elainebenes >
--  costanza81	< costanza81	jerry   	 kramer >
--  costanza81	< costanza81	elainebenes  	 jerry >
--  elainebenes	< elainebenes	jerry   	 costanza81 >
--  elainebenes	< elainebenes	jerry   	 elainebenes >
--  elainebenes	< elainebenes	jerry   	 kramer >
--  kramer	< kramer	jerry   	 costanza81 >
--  kramer	< kramer	jerry   	 elainebenes >
--  kramer	< kramer	jerry   	 kramer >
--
_f_tri_o	= FOREACH f_1hd GENERATE FLATTEN(inlinks) AS a, GROUP AS b, FLATTEN(outlinks) AS c	;

--  jerry	< jerry  	costanza81  	 jerry >
--  jerry	< jerry  	elainebenes  	 jerry >
--  jerry	< jerry  	kramer  	 jerry >
--  costanza81	< costanza81	jerry   	 costanza81 >
--  elainebenes	< elainebenes	jerry   	 elainebenes >
--  kramer	< kramer	jerry   	 kramer >
--
--  jerry	< jerry  	costanza81  	 elainebenes >
--  jerry	< jerry  	kramer  	 lomez >
--  costanza81	< costanza81	jerry   	 elainebenes >
--  costanza81	< costanza81	jerry   	 kramer >
--  costanza81	< costanza81	elainebenes  	 jerry >
--  elainebenes	< elainebenes	jerry   	 costanza81 >
--  elainebenes	< elainebenes	jerry   	 kramer >
--  kramer	< kramer	jerry   	 costanza81 >
--  kramer	< kramer	jerry   	 elainebenes >
--

_f_tri_io	= COGROUP _f_tri_io BY a AS inlinks, _f_tri_io BY b AS inlinks

