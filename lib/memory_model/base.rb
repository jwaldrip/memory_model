require 'active_support/core_ext/object'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/hash_with_indifferent_access'
require 'active_support/dependencies/autoload'
require 'securerandom'
require 'ice_nine'
require 'ice_nine/core_ext/object'

class MemoryModel::Base
  extend ActiveSupport::Autoload
  autoload :Fields
  autoload :Collectable

  include Fields
  include Collectable

  VALID_IVARS = [
    :@deleted,
    :@attributes,
    :@timestamp
  ]

  class << self

    def inherited(subclass)
      subclass.instance_variable_set :@collection, collection
      subclass.instance_variable_set :@fields, fields
      subclass.field :id, readonly: true, default: -> { SecureRandom.uuid }
    end

  end

  attr_reader :timestamp

  def initialize(attributes={ })
    raise MemoryModel::InvalidCollectionError unless self.class.collection?
    @attributes = fields.default_values(self, attributes)
    @deleted    = false
  end

  def has_attribute?(key)
    @attributes.fetch(key, nil).present?
  end

  def inspect
    inspection = if @attributes
                   self.class.fields.reduce([]) { |array, name|
                     array << "#{name}: #{attribute_for_inspect(name)}" if has_attribute?(name)
                     array
                   }.join(", ")
                 else
                   "not initialized"
                 end
    "#<#{self.class} #{inspection}>"
  end

  def commit
    @timestamp = Time.now
    self.class.insert self
    self
  end

  def delete
    @deleted = true
    commit
    freeze
  end

  def deleted?
    !!@deleted
  end

  def deleted_at
    deleted? ? @timestamp : nil
  end

  def dup
    deep_dup
  end

  def deep_dup
    Marshal.load Marshal.dump self
  rescue
    temp_class_id = [:TEMP, self.class.object_id.to_s(36)].join('_')
    MemoryModel::Base.const_set temp_class_id, self.class
    duplicate = deep_dup
    MemoryModel::Base.send :remove_const, temp_class_id
    duplicate
  end

  def freeze
    instance_variables.reject { |ivar| ivar.in? VALID_IVARS }.each do |ivar|
      remove_instance_variable ivar if instance_variable_defined?(ivar)
    end
    instance_variables.each { |ivar| instance_variable_get(ivar).freeze }
    deep_freeze
    super
  end

  def read_attribute(key)
    @attributes[key]
  end

  alias :[] :read_attribute

  def restore
    instance = frozen? ? self.dup : self
    instance.instance_variable_set :@deleted, false
    instance
  end

  def write_attribute(key, value)
    raise MemoryModel::InvalidFieldError, "#{key} is not a valid field" unless fields.include? key
    raise MemoryModel::FieldReadOnlyError, "#{key} is read only" if fields[key].options[:readonly]
    @attributes[key] = value
  end

  alias :[]= :write_attribute

  private

  def attribute_for_inspect(attr_name)
    value = read_attribute(attr_name)

    if value.is_a?(String) && value.length > 50
      "#{value[0..50]}...".inspect
    elsif value.is_a?(Date) || value.is_a?(Time)
      value.to_s
    else
      value.inspect
    end
  end

end