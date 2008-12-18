
-- A = load 'out/parsed-1/part-00000' using PigStorage('\t');
-- B = foreach A generate $0 as id;
-- dump B;
-- store B into 'id.out';
a = load 'temp/fiddle_data.tsv' using PigStorage('\t') AS (rel, id_a, id_b, user_a, userb_b, timestamp);
a_f_b = foreach a generate 0 AS outlink, 0 AS user_1, user_a AS user_2, user_b AS user_3; 

link_1 = foreach a generate user_b AS owner, 'link_1' AS outlink, user_a AS user_1, user_b AS user_2,      0 AS user_3; 
link_2 = foreach a generate user_a AS owner, 'link_2' AS outlink, 0      AS user_1, user_a AS user_2, user_a AS user_3; 

