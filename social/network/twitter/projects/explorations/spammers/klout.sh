cat spammers_with_tq.tsv | cut -f1 | ruby -ne 'require "rubygems"; require "imw"; user = $_.strip.downcase; id = (IMW.open("http://klout.com/#{user}").parse(:score => ".primary.skore")[:score] || "").gsub(/klout score/,"") rescue ""; p id.to_i; sleep 3' > spammer_klout_scores.tsv