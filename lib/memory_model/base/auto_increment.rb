module MemoryModel
  class Base
    module AutoIncrement

      extend ActiveSupport::Concern

      included do
        before_create(:auto_increment_fields!)
      end

      private

      def auto_increment_fields!
        fields.select { |field| field.options[:auto_increment] === true }.each do |field|
          write_attribute(field.name, self.class.auto_increment_for!(field.name))
        end
      end

      def reset_incremented_fields!
        fields.select { |field| field.options[:auto_increment] === true }.each do |field|
          clear_attribute(field.name)
        end
      end

      module ClassMethods

        def auto_increment_for!(field)
          fields[field].increment!
        end

      end

    end

    module Fields
      class Field

        def increment!
          raise ArguementError, "#{name} is not incrementable" unless options[:auto_increment] === true
          @incrementor ||= 0
          @incrementor += 1
        end

      end
    end
  end
end