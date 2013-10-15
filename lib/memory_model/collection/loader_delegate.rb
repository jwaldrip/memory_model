require 'active_support/cache'

class MemoryModel::Collection::LoaderDelegate < BasicObject

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
  delegate :count, :size, :length, to: :@records

  def initialize(records)
    @records = records
  end

  private

  def loaded_records
    ::MemoryModel::Collection::LoaderDelegate.cache.fetch(records_digest) do
      ::STDOUT.puts 'cache miss'
      @records.map(&:load)
    end
  end

  def records_digest
    ::Digest::MD5.hexdigest @records.map(&:string).join
  end

  def method_missing(m, *args, &block)
    loaded_records.send(m, *args, &block)
  end

end