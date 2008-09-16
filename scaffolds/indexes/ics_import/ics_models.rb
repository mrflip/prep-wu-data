#
# These are extra fields & classes not used by IMW in general
#
#
require 'imw/dataset/ics_models_more'
Dataset.class_eval do
  include DataMapper::Resource
  property      :delicious_taggings,    Integer,                     :index => :delicious_taggings
  property      :base_trust,            Integer
  property      :approved_at,           DateTime
  property      :approved_by,           Integer
end
