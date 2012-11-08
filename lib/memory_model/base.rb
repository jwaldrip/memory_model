class MemoryModel::Base < HashWithIndifferentAccess
  extend ActiveSupport::Autoload

  # Autoloads
  autoload :ClassMethods
  autoload :Attributes

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

  # Memory Model
  extend ClassMethods
  include Attributes
  include MemoryModel::Associations

  # Set Up Callbacks
  define_model_callbacks :create, :save, :destroy, :update, :initialize

  class_attribute :field_options, :fields, :collection, instance_writer: false

  private :field_options, :fields, :collection

  [:merge!, :merge].each { |method| undef_method method }

  self.collection = Set.new
  self.fields = Set.new
  self.field_options = HashWithIndifferentAccess.new

  field :id

  alias :klass :class

  def initialize(attrs={})
    self.attributes = attributes_with_defaults.merge(attrs)
  end

  def save
    found_instance = collection.find{ |item| item.id == id }
    if found_instance
      instance = found_instance.attributes=(self)
    else
      self.attributes = { id: klass.next_id }
      collection << instance = self.dup
    end

    instance
  end

end