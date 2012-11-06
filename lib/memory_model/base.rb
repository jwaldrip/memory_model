class MemoryModel::Base < Hash
  extend ActiveSupport::Autoload
  autoload :ClassMethods
  extend ClassMethods

  # Active Model
  extend  ActiveModel::Naming
  extend  ActiveModel::Callbacks
  extend  ActiveModel::Translation
  extend  ActiveModel::Callbacks
  include ActiveModel::MassAssignmentSecurity
  include ActiveModel::Conversion
  include ActiveModel::Dirty
  include ActiveModel::Observing
  include ActiveModel::Validations
  include ActiveModel::Serialization
  include ActiveModel::Serializers::JSON
  include ActiveModel::Serializers::Xml

  # Set Up Callbacks
  define_model_callbacks :create, :save, :destroy, :update, :initialize

  class_attribute :field_options, :fields, :collection, instance_writer: false

  self.collection = Set.new
  self.fields = Set.new
  self.field_options = {}

  field :id

  alias :klass :class

  def initialize(attrs={})
    attributes = fields.reduce({}) do |fields, key|
      fields[key] = nil
      fields
    end
    super.merge!(attributes_with_defaults.merge(attrs))
  end

  def merge(attrs={})
    attrs.assert_valid_keys(*fields)
    super
  end

  def merge!(attrs={})
    attrs.assert_valid_keys(*fields)
    super
  end

  alias_method :attributes= ,:merge!

  def []=(key, value)
    { key.to_sym => value }.assert_valid_keys(*fields)
    super
  end

  def save
    instance = self.collection.find{ |item| item[:id] == self[:id] } || self.merge!({ id: klass.next_id })
    self.collection << saved_instance = instance.dup
    saved_instance
  end

  def attribute(key, value=nil)
    if /(?<key>.*)=$/ =~ key
      self[key] = value
    else
      attributes[key]
    end
  end

  def attributes
    self.reduce(HashWithIndifferentAccess.new) do |attributes, (key, value)|
      attributes[key] = value
      attributes
    end
  end

  def inspect
    inspection = attributes.map do |key, value|
      "#{key}: #{attribute_for_inspect(key)}"
    end.join(", ")
    "#<#{self.class} #{inspection}>"
  end

  private

  def attributes_with_defaults
    self.reduce(HashWithIndifferentAccess.new) do |attributes, (key, value)|
      attributes[key] = value
      attributes
    end
  end

  def attribute_missing(match, *args, &block)
    self[match]
  end

  def attribute_for_inspect(attr)
    value = attributes[attr]
    if value.is_a?(String) && value.length > 50
      "#{value[0..50]}...".inspect
    else
      value.inspect
    end
  end

end