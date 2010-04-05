#!/usr/bin/env ruby

class MSDS
  attr_accessor :sections
  def initialize
    @sections = []
  end

  def read lines
    until lines.empty? do
      sections << one_section(lines)
    end
    p sections[4]
  end
  
  def one_section lines
    sct = MSDSSection.new
    sct.read(lines)
    sct.parse
  end
  
end

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
    hdr_mtchr = /\={4}([^\=]+)\={4}/
    section_hash = {}
    
    section.each do |line|
      if hdr_mtchr.match(line)
        section_hash['Header'] = $1
      else
        section_hash['Body'] ||= []
        section_hash['Body'] << line
      end
    end
    section_hash
  end
  
end

filename = ARGV[0]
sheet = MSDS.new
sheet.read( File.open(filename, 'r').readlines.reverse )


  
