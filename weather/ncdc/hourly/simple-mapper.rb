#!/usr/bin/env ruby


$stdin.each do |line|
  line = line.chomp.strip
  puts [line[0..22], line.split(/\s+/)].join("\t")
end
# STN--- WBAN   YEARMODA    TEMP       DEWP      SLP        STP       VISIB      WDSP     MXSPD   GUST    MAX     MIN   PRCP   SNDP   FRSHTT
# 100200 99999  19390910    64.5  6    55.8  6  1013.9  6  9999.9  0    9.7  6    7.6  6    8.9  999.9    66.0*   63.0* 99.99  999.9  010000

