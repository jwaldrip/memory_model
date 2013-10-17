require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/string'
require 'set'

module MemoryModel
  class Base
    module Fields
      class FieldSet < Set

        def [](name)
          find { |f| f.name == name.to_sym }
        end

        def add(name, options={})
          delete_if { |f| f == name }
          self << MemoryModel::Base::Fields::Field.new(name, options)
        end

        def include?(name)
          self[name].present?
        end

        def comparable
          select(&:comparable?).map(&:to_sym)
        end

        def set_default_values(model, attributes={})
          model.attributes = self.map(&:name).reduce(attributes.with_indifferent_access) do |hash, field|
            hash[field] ||= fetch_default_value(model, field)
            hash
          end
        end

        def set_default_value(model, field)
          model.write_attribute field, fetch_default_value(model, field)
        end

        def fetch_default_value(model, field)
          default = self[field].default
          send("fetch_value_using_#{default.class.name.underscore}", model, default)
        rescue NoMethodError => e
          raise ArgumentError, "#{default} must be a string, symbol, lambda or proc"
        end

        private

        def fetch_value_using_proc(model, proc)
          raise TypeError, 'value must be a Proc' unless proc.is_a? Proc
          if proc.lambda? && proc.arity == 0
            proc.call
          elsif proc.arity < 1
            model.instance_eval(&proc)
          elsif proc.arity == 1
            proc.yield model
          else
            raise ArgumentError, "#{proc} must have an arity of 0..1, got #{proc.arity}"
          end
        end

        def fetch_value_using_string(model, string)
          raise TypeError, 'value must be a String' unless string.is_a? String
          string
        end

        def fetch_value_using_symbol(model, symbol)
          raise TypeError, 'value must be a Symbol' unless symbol.is_a? Symbol
          model.instance_eval(&symbol)
        end

        def fetch_value_using_nil_class(model, nil_object)
          raise TypeError, 'value must be a NilClass' unless nil_object.is_a? NilClass
          nil
        end

        def method_missing(m, *args, &block)
          if to_a.respond_to? m
            to_a.send m, *args, &block
          else
            super
          end
        end

      end
    end
  end
end