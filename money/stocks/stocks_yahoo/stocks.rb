#!/usr/bin/env ruby

require 'rubygems'
require 'imw'

dataset = IMW::Dataset.new
dataset.add_path :all_stocks, File.expand_path("/data/rawd/money/stocks/stocks_yahoo" )

dataset.task :rip do
end

dataset.task :raw do
end

dataset.task :fix do
  exchanges = ['NYSE', 'AMEX', 'NASDAQ']
  letters = ('A'..'Z').to_a + ('0'..'9').to_a
  fields = {
    'daily_prices' => ["exchange", "stock_symbol", "date", "stock_price_open", "stock_price_high", "stock_price_low", "stock_price_close", "stock_volume", "stock_price_adj_close"],
    'dividends' => ["exchange", "stock_symbol", "date", "dividends"],
  }
  exchanges.each do |exchg|
    letters.each do |initial_letter|
      stock_history = {}
      stock_history_flat = { 'dividends' => [], 'daily_prices' => [] }
      path = dataset.path_to( :all_stocks, exchg+'-'+initial_letter+'/Symbol-*.csv' )
      puts "Working on letter #{initial_letter}, for #{exchg}"
      FileList[ path ].each do |stockfile|
        stock_measure, junk, stock_symbol = stockfile.to_s.match(/Symbol-(Div|Stk)-(\w+)-(\w+)\.csv/)[1..3]
        stock_measure = { 'Div' => 'dividends', 'Stk' => 'daily_prices' }[stock_measure]
        stock_history[stock_symbol] ||= {}
        stock_history[stock_symbol][stock_measure] = []
        first = true
        IMW.open( stockfile ).load.each do |row|
          if first then first = false ; next ; end
          flat_vals = [exchg, stock_symbol] + row.map(&:to_s)
          vals = Hash.zip(fields[stock_measure], flat_vals)
          if (stock_measure == 'daily_prices') then
            ["open", "high", "low", "close", "adj close"].each do |f|
              vals[f] = vals[f].to_f
            end
            vals["volume"] = vals["volume"].to_i
          else
            vals["dividends"] = vals["dividends"].to_f
          end
          stock_history[stock_symbol][stock_measure].push(vals)
          stock_history_flat[stock_measure].push(fields[stock_measure].map{|f| vals[f]})
        end
      end
      dump_path = dataset.path_to( :all_stocks, exchg )
      mkdir_p dump_path
      fields.each_key do |stk_msr|
        file_path = dump_path + '/'+exchg.to_s+'_'+stk_msr.to_s+'_'+initial_letter.to_s+'.csv'
        FasterCSV.open(file_path, 'wb' ) do |csv|
          csv << fields[stk_msr]
          stock_history_flat[stk_msr].each do |row|
            csv << row
          end
        end
      end
    end
  end
end

dataset.task :pkg do
end

dataset.task(:fix).invoke
