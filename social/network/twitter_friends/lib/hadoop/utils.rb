module Hadoop
  module Utils
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
end
