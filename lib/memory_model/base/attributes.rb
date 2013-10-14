module MemoryModel::Base::Attributes
  extend ActiveSupport::Concern
  include ActiveModel::AttributeMethods
  include ActiveModel::Dirty

  included do
    attr_reader :attributes
    delegate :to_hash, to: :attributes
    attribute_method_affix :prefix => 'reset_', :suffix => '_to_default!'
    attribute_method_prefix 'clear_'
  end

  def has_attribute?(key)
    case value = @attributes[key]
    when NilClass, String
      !value.nil?
    else
      value.present?
    end
  end

  def inspect
    inspection = if @attributes
                   fields.reduce([]) { |array, name|
                     array << "#{name}: #{attribute_for_inspect(name)}" if has_attribute?(name)
                     array
                   }.join(", ")
                 else
                   "not initialized"
                 end
    "#<#{[self.class, inspection].join(' ')}>"
  end

  def read_attribute(name)
    @attributes[name]
  end

  alias :[] :read_attribute

  def write_attribute(name, value)
    raise MemoryModel::InvalidFieldError,
          "#{name} is not a valid field" unless fields.include? name
    raise MemoryModel::FieldReadOnlyError,
          "#{name} is read only" if fields[name].options[:readonly]

    send "#{name}_will_change!" unless value == read_attribute(name) || new_record?
    @attributes[name] = value
  end

  alias :[]= :write_attribute

  protected

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

  private

  def reset_attribute_to_default!(attr)
    write_attribute attr, fields.default_values(self).with_indifferent_access[attr]
  end

  def clear_attribute(attr)
    write_attribute attr, nil
  end

end