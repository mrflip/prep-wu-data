
class IdempotentResource
  cattr_accessor :attr_mapping
  cattr_accessor :key_attrs
  def remap *vals
    vals[0]
  end
  def self.make *vals
    vals = remap(*vals)
    self.find_or_create(vals.slice(*key_attrs))
    self.attributes = vals
  end
end
