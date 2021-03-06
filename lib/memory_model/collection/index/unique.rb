module MemoryModel

  class NilValueError < IndexError

    def initialize(index)
      super "`#{index.name}` cannot be nil"
    end

  end

  class RecordNotUniqueError < IndexError

    def initialize(args)
      index, key = args
      super "`#{index.name}` with `#{key}` already exists"
    end

  end

  class Collection
    class Index
      class MemoryModel::Collection::Index::Unique < MemoryModel::Collection::Index

        delegate :values_at, to: :index

        # `create` should implement creating a new record, raising an error if an item with the matching storage id already
        # exists in the index.
        def create(key, item)
          raise(NilValueError, self) if key.nil? && !options[:allow_nil]
          raise(RecordNotUniqueError, [self, key]) if index.has_key?(key)
          return if key.nil?
          index[key] = item
        end

        # `update` should find a record in the collection by its storage_id, remove it, and add with the new value.
        def update(key, item)
          raise(RecordNotInIndexError, [self, item]) unless exists? item
          delete(item.uuid)
          create(key, item)
        end

        # `read` should find a record in the collection by its indexed_value, remove it, and add with the new value.
        def read(key)
          index[key]
        end

        # `delete` should find a record in the collection by its indexed_value, and remove it.
        def delete(key)
          index.delete_if { |k, value| key == value.uuid }
        end

        # `exists?` return whether or not an item with the given storage id exists.
        def exists?(item)
          index.any? { |key, value| item.uuid == value.uuid }
        end

        # `values` should return the values of the index
        def values
          index.values
        end

        private

        def where_using_default(matcher)
          [read(matcher)]
        end

        def where_using_proc(matcher)
          index.values_at *index.keys.select(&matcher)
        end

        def where_using_regexp(matcher)
          where_using_proc ->(key) { key =~ matcher }
        end

      end
    end
  end
end
