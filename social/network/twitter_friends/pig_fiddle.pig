
A = load 'out/parsed-1/part-00000' using PigStorage('\t');
B = foreach A generate $0 as id;
dump B;
store B into 'id.out';
