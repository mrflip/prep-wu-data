#!/usr/bin/env ruby
require 'rubygems'
# tokyo_tyrant is the C-ruby fast interface http://github.com/actsasflinn/ruby-tokyotyrant ; 'tokyotyrant' is the pure ruby one http://1978th.net/tokyotyrant/rubydoc/
require 'tokyo_tyrant'
require 'tokyo_tyrant/balancer'
require 'configliere' ; require 'configliere/commandline'
Settings.resolve!


# run as
#
#   cat /mnt/tmp/twitter_user_id.tsv | ~/ics/icsdata/social/network/twitter/apeyeye/tt_fiddle.rb
#
# start server with
#
#   ttserver -port 12001 /data/db/ttyrant/twitter_user-ids.tch
#
#

DB_UID = TokyoTyrant::DB.new('ip-10-218-71-212', 12001)
DB_SN  = TokyoTyrant::DB.new('ip-10-218-71-212', 12002)
DB_SID = TokyoTyrant::DB.new('ip-10-218-71-212', 12003)

# http://github.com/actsasflinn/ruby-tokyotyrant/blob/master/spec/tokyo_tyrant_balancer_db_spec.rb
# servers = [ '127.0.0.1', '127.0.0.1', '127.0.0.1', '127.0.0.1' ]
#  tb = TokyoTyrant::Balancer::Table.new(servers)


#
# FIXME -- use
#
#  db.mput("1"=>"number_1", "2"=>"number_2", "3"=>"number_3", "4"=>"number_4", "5"=>"number_5")
#  db.mget(1..3) # => {"1"=>"number_1", "2"=>"number_2", "3"=>"number_3"}
#


start_time = Time.now.utc.to_f ;
iter=0;
$stdin.each do |line|
  _r, id, scat, sn, pr, fo, fr, st, fv, crat, sid, full = line.chomp.split("\t");
  id = id.to_i ; sid = sid.to_i

  iter+=1 ;
  # break if iter > 200_000
  if (iter % 10_000 == 0)
    elapsed = (Time.now.utc.to_f - start_time)
    puts "%-20s\t%7d\t%7d\t%7.2f\t%7.2f\t%s" % [sn, fo.to_i, iter.to_i, elapsed.to_i, (iter.to_f/elapsed.to_f), (Settings[:read] ? '[READ]' : '[WRITE]')]
  end

  if Settings[:read]
    id = DB_SN.get(sn.downcase) ;
    info = DB_UID.get(id) ;
  else
    DB_UID.putnr(id,  [sn,sid,crat,scat].join(',')) unless id == 0
    DB_SN.putnr(sn.downcase, id)                    unless sn.empty?
    DB_SID.putnr(sid, id)                           unless sid == 0
  end
end
DB_UID.close
DB_SN.close
DB_SID.close

# require 'rubygems' ; require 'tokyo_tyrant'; DB_UID = TokyoTyrant::DB.new('ip-10-218-71-212', 12001) ; DB_SN  = TokyoTyrant::DB.new('ip-10-218-71-212', 12002) ; DB_SID = TokyoTyrant::DB.new('ip-10-218-71-212', 12003)
