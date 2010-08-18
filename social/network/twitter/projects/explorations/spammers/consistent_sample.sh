cat twitter_user_id | cut -f2,4 | ruby -ne 'l = $_.strip.split("\t"); puts l.last if (l.first.to_i % 194 == 21)'
