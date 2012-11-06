class MemoryModel::Base < Hash
  extend ActiveSupport::Autoload
  autoload :ClassMethods
  extend ClassMethods

  class_attribute :field_options, :fields, :collection, instance_reader: false, instance_writer: false

  self.collection = []
  self.fields = []
  self.field_options = {}

  alias :klass :class

  def save
    instance = klass.collection.find{ |item| item[:id] == self[:id] } || self.merge!({ id: klass.next_id })
    klass.collection << saved_instance = instance.dup
    saved_instance
  end

end