require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    "#{@class_name.underscore.downcase}s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
                foreign_key: "#{name.to_s.underscore}_id".to_sym,
                primary_key: :id,
                class_name: "#{name}".camelize
              }
    defaults.merge!(options)

    @foreign_key = defaults[:foreign_key]
    @primary_key = defaults[:primary_key]
    @class_name = defaults[:class_name]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
                foreign_key: "#{self_class_name.underscore}_id".to_sym,
                primary_key: :id,
                class_name: "#{name}".singularize.camelize
              }
    defaults.merge!(options)

    @foreign_key = defaults[:foreign_key]
    @primary_key = defaults[:primary_key]
    @class_name = defaults[:class_name]
  end

  def model_class
    "#{@class_name}".constantize
  end

end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    define_method("#{name}") do
      foreign_value = self.send(options.foreign_key)
      target = options.model_class
      target.where(id: foreign_value).first
    end
  end

  def has_many(name, options = {})
    options = BelongsToOptions.new(name, options)
    define_method("#{name}s") do
      foreign_value = self.send(options.foreign_key)
      target = options.model_class
      target.where(id: foreign_value)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
