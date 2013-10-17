module MemoryModel

  class RecordNotFoundError < Error ; end

  class Collection
    module Finders

      def all
        LoaderDelegate.new records
      end

      def count
        _uuids_.count
      end

      def find(key)
        read(key).load
      rescue NoMethodError
        raise RecordNotFoundError
      end

      def find_all(*ids)
        read_all(*ids).map(&:load)
      end

      def find_by(hash)
        where(hash).first
      end

      def find_or_initialize_by(hash)
        find_by(hash) || model.new(hash)
      end

      def find_or_create_by(hash)
        find_by(hash) || model.create(hash)
      end

      def find_or_create_by!(hash)
        find_by(hash) || model.create!(hash)
      end

      def where(hash)
        matched_ids = hash.symbolize_keys.reduce(_uuids_) do |array, (attr, value)|
          records = indexes.has_key?(attr) ? where_in_index(attr, value) : where_in_all(attr, value)
          array & records.compact.map(&:uuid)
        end
        load_all(*matched_ids)
      end

      private

      def _uuids_
        indexes[:_uuid_].keys
      end

      def records
        indexes[:_uuid_].values
      end

      def where_in_all(attr, value)
        all.select { |record| record.read_attribute(attr) == value }
      end

      def where_in_index(attr, value)
        indexes[attr].where value
      end

    end
  end
end
