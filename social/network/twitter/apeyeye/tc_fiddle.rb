#!/usr/bin/env ruby
require 'rubygems' ;
require 'tokyo_tyrant' ;
include TokyoCabinet ;

# run as
#
#   cat /mnt/tmp/twitter_user_id.tsv | ~/ics/icsdata/social/network/twitter/apeyeye/tt_fiddle.rb
#
# start server with
#
#   ttserver -port 12001 /data/db/ttyrant/twitter_user-ids.tch
#
#

DB_UID = TokyoTyrant::DB.new('ip-10-218-71-212:12001'
# DB_SN = HDB::new  ; DB_SN.open( "/mnt/tmp/twitter_users-sn.tch",  HDB::OWRITER | HDB::OCREAT)
# DB_SID = HDB::new ; DB_SID.open("/mnt/tmp/twitter_users-sid.tch", HDB::OWRITER | HDB::OCREAT)

start_time = Time.now.utc.to_f ;
iter=0;
$stdin.each do |line|
  _r, id, scat, sn, pr, fo, fr, st, fv, crat, sid, full = line.chomp.split("\t");
  id = id.to_i ; sid = sid.to_i

  iter+=1 ;
  # break if iter > 200_000
  if (iter % 10_000 == 0)
    elapsed = (Time.now.utc.to_f - start_time)
    puts "%-20s\t%7d\t%7d\t%7.2f\t%7.2f" % [sn, fo.to_i, iter.to_i, elapsed.to_i, (iter.to_f/elapsed.to_f)]
  end

  # DB_SN.putasync(sn.downcase, id)                    unless sn.empty?
  # DB_SID.putasync(sid, id)                           unless sid == 0
  DB_UID.putasync(id,  [sn,sid,crat,scat].join(',')) unless id == 0
end
DB_UID.sync ; DB_UID.close
# DB_SID.sync ; DB_SID.close
# DB_SN.sync  ; DB_SN.close
