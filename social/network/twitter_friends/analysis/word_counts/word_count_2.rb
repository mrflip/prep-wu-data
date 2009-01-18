#!/usr/bin/env ruby

def key_freq freq
  logkey = ( 10*Math.log10(freq) ).floor
  "%03d\t%010d" % [1000-logkey, (2**30)-freq]
end

%x{/usr/bin/uniq -c}.split("\n").each do |line|
  freq, word = line.chomp.strip.split(/\s+/)
  freq = freq.to_i
  # next if freq <= 1
  puts [key_freq(freq), "% 10d"%freq, word].join("\t")
end
