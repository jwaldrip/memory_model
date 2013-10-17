module MemoryModel
  class Collection
    class MarshaledRecord

      attr_reader :uuid, :string

      def initialize(record)
        @uuid   = record._uuid_
        @string = Marshal.dump record
        freeze
      end

      def load
        Marshal.load @string
      end

      def ==(other_object)
        uuid == other_object.try(:uuid)
      end

    end
  end
end
