module MemoryModel::Base::Attributable
  extend ActiveSupport::Concern

  included do
    attr_reader :attributes
    delegate :to_hash, to: :attributes
    attribute_method_affix :prefix => 'reset_', :suffix => '_to_default!'
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
                   self.class.fields.reduce([]) { |array, name|
                     array << "#{name}: #{attribute_for_inspect(name)}" if has_attribute?(name)
                     array
                   }.join(", ")
                 else
                   "not initialized"
                 end
    "#<#{self.class} #{inspection}>"
  end

  def read_attribute(key)
    @attributes[key]
  end

  alias :[] :read_attribute

  def write_attribute(key, value)
    raise MemoryModel::InvalidFieldError, "#{key} is not a valid field" unless fields.include? key
    raise MemoryModel::FieldReadOnlyError, "#{key} is read only" if fields[key].options[:readonly]
    @attributes[key] = value
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

end