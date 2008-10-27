#
require File.dirname(__FILE__)+'/struct_dumper'

class HashOfStructs
  attr_accessor :klass, :objs
  def initialize klass
    self.klass = klass
    self.objs   = {}
  end


  def dump()    StructDumper.dump_objs objs, [:yaml, :xml, :csv]        end
  def load()    self.objs = StructDumper.load_yaml :dir => :data        end
  def save()    StructDumper.dump_yaml objs, :dir => :data              end
end

