module MemoryModel
  class Base
    module Actions
      module ClassMethods

        def create(attributes={})
          new(attributes).tap(&:save)
        end

        def create!(attributes={})
          new(attributes).tap(&:save!)
        end

        def delete_all
          count.tap do
            self.collection.clear
          end
        end

        def destroy_all
          self.all.each(&:destroy)
        end

      end
    end
  end
end