#!/usr/bin/env ruby
# tokyo_tyrant is the C-ruby fast interface http://github.com/actsasflinn/ruby-tokyotyrant ; 'tokyotyrant' is the pure ruby one http://1978th.net/tokyotyrant/rubydoc/
require 'rubygems'
require File.dirname(__FILE__)+'/tyrant_db'
require 'configliere' ; require 'configliere/commandline'
Settings.resolve!

# require 'rubygems'; require 'tokyo_tyrant' ; require 'tokyo_tyrant/balancer' ; servers = ['10.212.118.5', '10.245.217.162',] ; hdb = TokyoTyrant::Balancer::DB.new(servers)

# run as
#
#   cat /mnt/tmp/twitter_user_id.tsv | ~/ics/icsdata/social/network/twitter/apeyeye/tt_fiddle.rb
#
# start server with
#
#   ttserver -port 12001 /data/db/ttyrant/twitter_user-ids.tch
#
# 

# http://github.com/actsasflinn/ruby-tokyotyrant/blob/master/spec/tokyo_tyrant_balancer_db_spec.rb
      
#
# FIXME -- use
#
#  db.mput("1"=>"number_1", "2"=>"number_2", "3"=>"number_3", "4"=>"number_4", "5"=>"number_5")
#  db.mget(1..3) # => {"1"=>"number_1", "2"=>"number_2", "3"=>"number_3"}
#

start_time = Time.now.utc.to_f ;
iter=0;
UID_DB = TyrantDb.new(:uid)
SN_DB  = TyrantDb.new(:sn)
SID_DB = TyrantDb.new(:sid)
TEST_DB = TyrantDb.new(:test)

$stdin.each do |line|
  _r, id, scat, sn, pr, fo, fr, st, fv, crat, sid, full = line.chomp.split("\t");
  id = id.to_i ; sid = sid.to_i
  
  iter+=1 ;
  # break if iter > 500_000
  if (iter % 10_000 == 0)
    elapsed = (Time.now.utc.to_f - start_time)
    puts "%-20s\t%7d\t%7d\t%7.2f\t%7.2f\t%s" % [sn, fo.to_i, iter.to_i, elapsed.to_i, (iter.to_f/elapsed.to_f), (Settings[:read] ? '[READ]' : '[WRITE]')]
  end

  if Settings[:read]
    # id = SN_DB.get(sn.downcase) ;
    # info =  UID_DB.get(id) ;
    info = TEST_DB[id]
    puts [iter, id, info].inspect if info.nil?
  else
    # UID_DB.insert_array(id, [sn,sid,crat,scat]) unless id == 0
    # SN_DB.insert(sn.downcase, id)                   unless sn.empty?
    # SID_DB.insert(sid, id)                          unless sid == 0
    TEST_DB.insert(id, sn.downcase) unless sn.empty? || id == 0
  end
end
UID_DB.close
SN_DB.close
SID_DB.close
TEST_DB.close

# require 'rubygems' ; require 'tokyo_tyrant'; UID_DB = TokyoTyrant::DB.new('ip-10-218-71-212', 12001) ; DB_SN  = TokyoTyrant::DB.new('ip-10-218-71-212', 12002) ; DB_SID = TokyoTyrant::DB.new('ip-10-218-71-212', 12003)
