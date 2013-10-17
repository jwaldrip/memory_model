module MemoryModel

  class IndexError < Error
  end

  class InvalidWhereQuery < IndexError

    def initialize(matcher_class)
      super "Unable to perform a where with #{matcher_class}"
    end

  end

  class RecordNotInIndexError < IndexError

    def initialize(args)
      item, index = args
      super "record `#{item.uuid}` is missing from index `#{index.name}`"
    end

  end

  class Collection
    class Index
      extend ActiveSupport::Autoload

      autoload :Unique
      autoload :Multi

      attr_reader :name, :options, :index

      delegate :clear, :keys, to: :index
      delegate :count, to: :values

      def initialize(name, options)
        @name    = name
        @options = options
        @index   = {}
      end

      # This is the base index, each method below must be implemented on each subclass

      # `create` should implement creating a new record, raising an error if an item with the matching storage id already
      # exists in the index.
      def create(key, item)
        raise NotImplementedError, "#{__method__} has not been implemented for this #{name} index"
      end

      # `update` should find a record in the collection by its storage_id, remove it, and add with the new value.
      def update(key, item)
        raise NotImplementedError, "#{__method__} has not been implemented for this #{name} index"
      end

      # `read` should find a record in the collection by its indexed_value, remove it, and add with the new value.
      def read(key)
        raise NotImplementedError, "#{__method__} has not been implemented for this #{name} index"
      end

      # `delete` should find a record in the collection by its indexed_value, and remove it.
      def delete(key)
        raise NotImplementedError, "#{__method__} has not been implemented for this #{name} index"
      end

      # `exists?` return whether or not an item with the given storage id exists.
      def exists?(item)
        raise NotImplementedError, "#{__method__} has not been implemented for this #{name} index"
      end

      # `where` should allow me to specify complex arguments and return an array
      def where(matcher)
        matcher_class = matcher.class.name.underscore
        send("where_using_#{matcher_class}", matcher)
      rescue NoMethodError
        respond_to?(:where_using_default, true) ? where_using_default(matcher) :
          raise(InvalidWhereQuery, matcher_class)
      end

      # `values` should return the values of the index
      def values
        raise NotImplementedError, "#{__method__} has not been implemented for this #{name} index"
      end

    end
  end
end

