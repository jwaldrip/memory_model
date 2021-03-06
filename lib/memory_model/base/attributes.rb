require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/hash_with_indifferent_access'

module MemoryModel
  class Base
    module Attributes
      extend ActiveSupport::Concern
      include ActiveModel::AttributeMethods
      include ActiveModel::Dirty

      included do
        delegate :to_hash, to: :attributes
        attribute_method_affix prefix: 'reset_', suffix: '_to_default!'
        attribute_method_prefix 'clear_'
      end

      def attributes
        @attributes ||= HashWithIndifferentAccess.new
      end

      def attributes=(hash)
        hash.reduce({}) do |hash, (attr, value)|
          hash.merge attr => write_attribute(attr, value)
        end
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
        inspection = fields.reduce([]) { |array, field|
          name = field.name
          array << "#{name}: #{attribute_for_inspect(name)}" if has_attribute?(name)
          array
        }.join(", ")
        inspection = ' ' + inspection if inspection.present?
        super.sub /^(#<[a-z:0-9]+).*>/i, "\\1#{inspection}>"
      end

      def read_attribute(name)
        attributes[name]
      end

      alias :[] :read_attribute

      def write_attribute(name, value)
        raise InvalidFieldError, name unless fields.include? name
        raise ReadOnlyFieldError, name if fields[name].options[:readonly] && persisted?

        send "#{name}_will_change!" unless read_attribute(name) == value || new_record?
        attributes[name] = value
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

      def clear_attribute(attr)
        write_attribute attr, nil
      end

      def reset_attribute_to_default!(attr)
        fields.set_default_value(self, attr)
      end

    end
  end
end
