#!/usr/bin/env ruby

#
# prepare the IDs list with
#
#
# last_parse=out/`date "+%Y%m%d"`-sorted-uff ;
# hdp-stream "$last_parse/twitter_user_partial.tsv,$last_parse/twitter_user.tsv" \
#    out/user_names_and_ids \
#    /home/flip/ics/pool/social/network/twitter_friends/twitter_bundle_json-gen_usernames.rb /usr/bin/uniq \
#    2 -jobconf mapred.reduce.tasks=1
# ( echo "ID_LIST={" ; hdp-cat out/user_names_and_ids/'part*' ; echo "}" ) > fixd/dump/user_names_and_ids_20081220.rb
#


$stdin.each do |line|
  _, _, _, id, screen_name, _ = line.chomp.split("\t",6)
  next unless screen_name =~ /\A\w+\z/
  puts "  '%s'\t=> %d," % [screen_name, id.to_i]
end
