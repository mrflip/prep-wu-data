Reqs = LOAD '/data/rawd/social/network/twitter/scrape_stats/requests_metadata/*/part-*'
  AS (rsrc: chararray, req_id: long, page: long, date: long, response: int);

ReqsHist_0 = FOREACH Reqs GENERATE rsrc ;
ReqsHist_1 = GROUP   ReqsHist_0 BY rsrc PARALLEL 5;
ReqsHist   = FOREACH ReqsHist_1 GENERATE group AS rsrc, COUNT(ReqsHist_0) AS num  ;
-- ILLUSTRATE ReqsHist ;

rmf                  /data/rawd/social/network/twitter/scrape_stats/requests_metadata/reqs_hist
STORE ReqsHist INTO '/data/rawd/social/network/twitter/scrape_stats/requests_metadata/reqs_hist' ;
