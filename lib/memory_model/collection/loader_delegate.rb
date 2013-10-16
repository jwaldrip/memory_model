require 'active_support/cache'
require 'active_support/core_ext/module/delegation'

class MemoryModel::Collection::LoaderDelegate < BasicObject
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

  delegate_and_load :first, :last
  delegate :count, :size, :length, :present?, :blank?, to: :@records
  delegate :inspect, to: :loaded_records

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
    ::MemoryModel::Collection::LoaderDelegate.ancestors.map(&:instance_methods).flatten.uniq
  end

  def class
    ::MemoryModel::Collection::LoaderDelegate
  end

  private

  def loaded_records
    ::MemoryModel::Collection::LoaderDelegate.cache.fetch(records_digest) do
      @records.map(&:load)
    end
  end

  def records_digest
    ::Digest::MD5.hexdigest @records.map(&:string).join
  end

end