require 'active_support/cache'
require 'active_support/core_ext/module/delegation'

module MemoryModel
  class Collection
    class LoaderDelegate < BasicObject
      include ::Enumerable

      class << self
        def delegate_and_load(*methods)
          methods.each do |method|
            define_method method do |*args, &block|
              @records.send(method, *args, &block).try(:load)
            end
          end
        end

        def cache
          @cache ||= ::ActiveSupport::Cache.lookup_store :memory_store
        end
      end

      delegate_and_load :first, :last, :sample
      delegate :count, :size, :length, :present?, :blank?, to: :@records
      delegate :to_s, :pretty_inspect, :inspect, to: :loaded_records

      def initialize(records)
        @records = records
      end

      def each(&block)
        loaded_records.each(&block)
      end

      def kind_of?(klass)
        klass == self.class
      end

      alias is_a? kind_of?

      def methods
        LoaderDelegate.ancestors.map(&:instance_methods).flatten.uniq
      end

      def class
        LoaderDelegate
      end

      private

      def loaded_records
        LoaderDelegate.cache.fetch(records_digest) do
          @records.map(&:load)
        end
      end

      def records_digest
        ::Digest::MD5.hexdigest @records.map(&:string).join
      end

    end
  end
end