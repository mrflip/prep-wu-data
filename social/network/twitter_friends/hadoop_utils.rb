require 'rubygems'
require 'faster_csv'
module HadoopUtils

  #
  # Handy Monkeypatching
  #
  String.class_eval do
    # Stolen from active_support
    #
    # The reverse of +camelize+. Makes an underscored, lowercase form from the expression in the string.
    #
    # Changes '::' to '/' to convert namespaces to paths.
    #
    # Examples:
    #   "ActiveRecord".underscore         # => "active_record"
    #   "ActiveRecord::Errors".underscore # => active_record/errors
    def underscore
      gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end
    #
    # Strip control characters that might harsh our buzz, TSV-wise
    #
    def scrub!
      gsub!(/[\t\r\n]+/, ' ')  # KLUDGE
    end
    #
    # add a method exactly like +parse_csv+ but specifying a tab-separator
    #
    def parse_tsv options={}
      parse_csv options.merge( :col_sep => "\t" )
    end
  end
  Array.class_eval do
    #
    # add a method exactly like +parse_csv+ but specifying a tab-separator
    #
    def to_tsv options={}
      to_csv options.merge( :col_sep => "\t" )
    end
  end
  #
  # For each of the given fields, strip any control characters that might harsh
  # our buzz, TSV-wise
  #
  def scrub hsh, *fields
    fields.each{|field| hsh[field.to_s].scrub! if hsh[field.to_s] }
  end

  class LineTimestampUniqifier
    attr_accessor :last_line
    def initialize
      self.last_line = nil
    end
    def is_repeated? line
      # Strip the timestamp (last field on the line -- we don't need to do any complicated TSV decoding for that
      this_line = line.gsub(/\t\d{14}\s*$/,'')
      # Since the only things that will be de-uniqued have all-identical
      # prefixes (differ only in their timestamp), and the lines are lexically
      # sorted (?) this should be the earliest
      if this_line == self.last_line
        true
      else
        self.last_line = this_line
        false
      end
    end
  end

  module HadoopStructMethods
    def initialize timestamp, hsh
      # self.origin = origin
      self.timestamp = timestamp
      self.indifferent_merge! hsh
    end
    #
    def resource
      "%s_%s" % [self.class.key_index, self.class.to_s.underscore]
    end
    # identifying output key
    def key owner
      [owner, resource]
    end
    # dump to stdout
    def emit owner
      puts [ key(owner), *self.values ].flatten.to_tsv
    end
    #
    def parse
      # subclass
    end
  end

  class HadoopStruct < Struct
    def self.new key_index, *members
      klass = super(*[members, :timestamp].flatten)
      klass.class_eval do
        include HadoopStructMethods
        cattr_accessor :key_index
        self.key_index = key_index
      end
      klass
    end
  end
end
