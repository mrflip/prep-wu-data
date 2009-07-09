RUBYLIB=$HOME/ics/wukong/lib:$RUBYLIB ruby -e 'require "rubygems"; require "faster_csv"; require "wukong" ; require "wukong/encoding" ; Dir
["fixd/Symbol-Name-*.csv"].each do |fn| FasterCSV.open(fn) do |f| f.each do |row| puts row[0..2].map{|s| Wukong.encode_str(s, :url) }.join("\t") ; end ; end; end'
