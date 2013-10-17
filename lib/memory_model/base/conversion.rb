module MemoryModel
  class Base
    module Conversion

      def to_key
        persisted? ? [id] : nil
      end

    end
  end
end