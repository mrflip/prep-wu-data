for table in friendships users statuses ; do
  for n in 10 11 12 13 14 15 16 ; do
    file="twitter_friends-lab${n}" ;
    echo ${file}-${table}.tsv ;
    echo ".mode tabs
          .output ${file}-${table}.tsv
          SELECT * FROM ${table}; " | sqlite3 ${file}.sqlite;
  done
done
