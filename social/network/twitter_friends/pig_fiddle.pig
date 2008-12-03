
A = load 'rawd/social/network/twitter_friends-20081202/statuses/followers/_az.tsv' using PigStorage('-');
B = foreach A generate $0 as id;
dump B;
store B into 'id.out';
