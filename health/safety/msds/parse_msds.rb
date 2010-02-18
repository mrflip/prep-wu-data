#!/usr/bin/env ruby

class MSDSSection
  attr_accessor :section
  def initialize
    @section = []
  end

  def read lines
    until lines.empty? do
      line = lines.pop
      if end_of_section?(line)
        lines.push line
        return
      end
      accumulate line
    end
  end

  def end_of_section? line
    return true if line.to_s.include? '====' and section.size > 0
    return false
  end

  def accumulate line
    section << sanitize(line)
  end

  #do away with html tags
  def sanitize line
    reg = /<[^<>]+>/
    line.gsub(reg,"")
  end

  def parse
    section_hsh = {}
    field_mtchr = /^([^:]+):(.+)$/
    hdr_mtchr = /\={4}([^\=]+)\={4}/
    #run through each line in the section and extract the fields and associated data
    section.each do |line|
      field_mtchr.match(line)
      section_hsh[$1] = $2 unless $1 == nil
    end
    hdr_mtchr.match(section[0])
    section_hsh['Header'] = $1.strip unless $1 == nil
    section_hsh
  end
end

filename = ARGV[0]
lines = File.readlines(filename).reverse
info_section = MSDSSection.new
info_section.read(lines)
p info_section.section
p info_section.parse
comp_section = MSDSSection.new
comp_section.read(lines)
p comp_section.parse
