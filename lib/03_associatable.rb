require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

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
    assoc_options[name] = options
    define_method(name) do
      foreign_value = self.send(options.foreign_key)
      target = options.model_class
      target.where(id: foreign_value).first
    end
  end

  def has_many(name, options = {})
    self_class_name = self.to_s
    options = HasManyOptions.new(name, self_class_name, options)
    define_method(name) do
      key = options.foreign_key
      value = self.send(options.primary_key)
      target = options.model_class
      target.where(key => value)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
