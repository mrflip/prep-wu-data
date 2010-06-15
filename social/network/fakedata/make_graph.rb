#!/usr/bin/env ruby
require 'wukong'

class Edge < Struct.new(:a, :b, :symm)
end

edges = {}
File.open('a_follows_b-input.tsv').each do |line|
  line = line.gsub(/#.*/,"").strip
  a, b = line.split(/\s+/, 2)
  next unless a && b
  edges[[a,b]] = Edge.new(a,b)
end

edges.each do |pair, edge|
  edge.symm = 1 if (edge.a < edge.b) && (edges[[edge.b, edge.a]])
end

File.open('a_follows_b-processed.tsv', 'w') do |out_file|
  edges.values.each do |edge|
    # out_file << [edge.a, edge.b, (edge.symm ? 1 : 0)].join("\t")
    $stdout << [edge.a, edge.b, (edge.symm ? 1 : 0)].join("\t")+"\n"
  end
end
