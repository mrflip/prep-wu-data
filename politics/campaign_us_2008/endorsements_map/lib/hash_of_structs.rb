#
require File.dirname(__FILE__)+'/struct_dumper'

module HashOfStructs
  module ClassMethods
    def all() @all = @all || load  end
    def all=(newall) @all = newall      end

    def [](*key_vals)
      all[ make_key(*key_vals) ]
    end
    def add(*vals)
      if (vals.length==1) && (vals.first.is_a? self)
        obj = vals.first
      else
        obj = new(*vals)
      end
      @all[ obj.key ] = obj
    end
    #
    # serialize
    #
    def load options={ }
      options = options.reverse_merge :dir => :data, :literalize_keys => true
      puts Time.now.to_s+" Loading #{self}"
      self.all = StructDumper.load_tsv self, options
      self.all
    end
    def dump options={ }
      options = options.reverse_merge :dir => :data, :literalize_keys => true
      puts Time.now.to_s+" Dumping #{self}"
      StructDumper.dump_tsv @all, options
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end

