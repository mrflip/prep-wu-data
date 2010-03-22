#!/usr/bin/env ruby

# Only designed to parse msds from Hazard.com
class Msds_Parser
  attr_accessor :field_mtchr, :num_mtchr, :field_delim, :html_mtchr, :section_body, :section_hdr, :sheet
  def initialize
    @field_mtchr = /\={4}([^\=]+)\={4}/
    @num_mtchr = /^\d{1,2}\./
    @field_delim = /\={4}+/
    @html_mtchr = /<[^<>]+>/
    @section_body = []
    @sheet = {}
  end

  #expects a reversed hazrd msds file
  def read lines
    until lines.empty?
      line = lines.pop
      unless line.match field_mtchr
        @section_body << line
      else
        finish_section
        start_new_section line
      end
    end
  end

  def start_new_section line
    @section_hdr = get_field_title(line)
  end

  def finish_section
    @sheet[section_hdr] = section_body
    @section_body = []
  end

  def get_field_title line
    field_mtchr.match(line)
    field = $1
    unless  field == nil
      field = $1.strip
    else
      field = "Other"
    end
    field
  end
end

filename = ARGV[0]
data = File.open(filename, 'r')
prsr = Msds_Parser.new
prsr.read( File.readlines(filename).reverse )
prsr.sheet.each{ |k,v| puts "#{k} => #{v}" }

