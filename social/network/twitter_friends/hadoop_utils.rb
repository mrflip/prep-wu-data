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
      gsub!(/\\/, '/') # hadoop is barfing on double backslashes. sorry, backslashes.
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

  module HadoopStructMethods
    module ClassMethods
      def new_from_hash scraped_at, hsh
        struct = new
        struct.scraped_at = scraped_at
        struct.indifferent_merge! hsh
        struct
      end
    end
    #
    def resource
      self.class.to_s.underscore
    end
    # identifying output key
    def key
      self.values_of(*self.class.key_fields).join('-')
    end
    # dump to stdout
    def emit
      puts [ resource, key, *self.values ].flatten.to_tsv
    end
    #
    def parse
      # subclass
    end
    def self.included base
      base.extend ClassMethods
    end
  end

  class HadoopStruct < Struct
    def self.new key_fields, *members
      klass = super(*[:scraped_at, members].flatten)
      klass.class_eval do
        include HadoopStructMethods
        cattr_accessor :key_fields
        self.key_fields = key_fields
      end
      klass
    end
  end
end
