#!/usr/bin/env ruby
require 'fileutils'; include FileUtils::Verbose
ARGV.each do |file|
  file = File.expand_path file
  dest = file.gsub(%r{ics/pool/scaffolds/old_schemata}, "ics/pool/scaffolds/pool_schemata")
  mkdir_p File.dirname(dest)
  mv file, dest
  `open #{dest} -a Emacs.app`
end
