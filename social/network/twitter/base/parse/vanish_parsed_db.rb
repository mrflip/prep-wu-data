#!/usr/bin/env ruby
require 'rubygems'
require 'wukong/keystore/tyrant_db.rb'

[:tweets_parsed, :users_parsed].each do |db_cnxn|
  db_obj = TokyoDbConnection::TyrantDb.new(db_cnxn)
  db_obj.db.vanish
end
