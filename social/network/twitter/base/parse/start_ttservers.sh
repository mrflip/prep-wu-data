#!/usr/bin/env sh
mkdir -p /data/db/ttyrant
ttserver -port 12001 /data/db/ttyrant/user_ids.tch#bnum=100000000#opts=l &
ttserver -port 12002 /data/db/ttyrant/screen_names.tch#bnum=100000000#opts=l &
ttserver -port 12003 /data/db/ttyrant/search_ids.tch#bnum=100000000#opts=l &
ttserver -port 12004 /data/db/ttyrant/tweets_parsed.tch#bnum=800000000#opts=l &
ttserver -port 12005 /data/db/ttyrant/users_parsed.tch#bnum=100000000#opts=l &
