#!/usr/bin/env ruby

class MSDS
  #each one is an msds section capable of parsing itself
  attr_accessor :sections
  def initialize
    @sections = {
      :product_identification,
      :composition,
      :hazards,
      :first_aid,
      :fire_fighting,
      :accidental_release,
      :handling,
      :properties,
      :reactivity,
      :toxicology,
      :ecology,
      :disposal,
      :regulations,
      :other,
    }
  end

  #kill first line of file and read line has a header
  def read lines
    sections.each_value do |sct|
      sct = MSDSSection.new
      sct.read(lines)
      p sct.parse
    end
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
    sections = []
    sub_hsh = {}
    field_mtchr = /^([^:]+):(.+)/
    hdr_mtchr = /\={4}([^\=]+)\={4}/
    sub_mtchr = /\=([^\=]+)\=/
    line_str = ""
    section.each do |line|
      #if subsection make a new hash to fill
      if start_subsection?(line)
        sections << sub_hsh
        sub_hsh = {}
        sub_mtchr.match(line)
        sub_hsh['Header'] = $1
      else
        line_str += line.to_s
        unless line.include?("    ")
          if field_mtchr.match(line_str.strip)
            sub_hsh[$1] = $2
            line_str = ""
          end
        end
      end
    end
    sections
  end
  
  
  def start_subsection?(line)
    return true if line.include?("=")
    return false
  end

end

filename = ARGV[0]
sheet = MSDS.new
sheet.read( File.open(filename, 'r').readlines.reverse )


