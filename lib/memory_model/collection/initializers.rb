module MemoryModel
  class Collection
    module Initializers
      extend ActiveSupport::Concern

      def initialize(model)
        @model = model
        set_primary_key :_uuid_, default: nil
      end

      def add_index(name, options={})
        type          = :unique if options.delete(:unique)
        type          ||= options.delete(:type) || :multi
        indexes[name] = Index.const_get(type.to_s.camelize).new(name, options)
      rescue NameError => e
        raise TypeError, "#{type.inspect} is not a valid index"
      end

      def indexes
        @indexes ||= {}
      end

      def index_names
        indexes.keys
      end

      def set_primary_key(key, options={})
        if options[:auto_increment] != false && !options.has_key?(:default)
          options[:auto_increment] = true
        end
        options[:comparable] ||= false
        @model.field key, options
        add_index key, type: :unique
        @primary_key = key
      end

      module ClassMethods

        def all
          MemoryModel::Collection.instance_variable_get(:@all) ||
            MemoryModel::Collection.instance_variable_set(:@all, [])
        end

      end

    end
  end
end
