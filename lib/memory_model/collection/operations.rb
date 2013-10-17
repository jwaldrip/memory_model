module MemoryModel
  class Collection
    module Operations

      def clear
        indexes.each { |name, index| index.clear }
      end

      def read_all(*ids)
        return [] if ids.blank?
        indexes[primary_key].values_at(*ids).compact
      end

      def load_all(*uuids)
        return [] if uuids.blank?
        indexes[:_uuid_].values_at(*uuids).compact.map(&:load)
      end

      def create(item)
        item._uuid_ = SecureRandom.uuid
        transact item, operation: :create, rollback_with: :delete
      end

      def read(key)
        indexes[primary_key].read(key)
      end

      def update(item)
        transact item, operation: :update, rollback_with: :rollback
      end

      def delete(item)
        transact item, operation: :delete
      end

      private

      def transact(record, options={})
        # Set up the index
        successful_indexes = []

        # Fetch the options
        operation          = options[:operation] || :undefined
        indexes            = options[:indexes] || self.indexes.values
        rollback_operation = options[:rollback_with]

        # Marshal the object
        marshaled_record   = MarshaledRecord.new(record)

        # Do the transaction
        indexes.map do |index|
          send("#{operation}_with_index", index, record, marshaled_record).tap do
            successful_indexes << index
          end
        end
      rescue Exception => e
        transact(record, operation: rollback_operation, indexes: successful_indexes) if rollback_operation
        raise e
      end

      ## Transactors
      def create_with_index(index, record, marshaled_record)
        index.create record.read_attribute(index.name), marshaled_record
      end

      def update_with_index(index, record, marshaled_record)
        index.update record.read_attribute(index.name), marshaled_record
      end

      def rollback_with_index(index, record, marshaled_record)
        index.update record.changed_attributes[index.name], marshaled_record
      end

      def delete_with_index(index, record, marshaled_record)
        index.delete marshaled_record.uuid
      end

    end
  end
end