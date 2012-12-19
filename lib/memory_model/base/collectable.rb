require 'active_support/concern'

module MemoryModel::Base::Collectable
  extend ActiveSupport::Concern

  module ClassMethods
    delegate :all, :find, :insert, :<<, :deleted, to: :collection

    def collection?
      !!collection
    end

    private

    def collection
      return nil if self == MemoryModel::Base
      @collection ||= MemoryModel::Collection.new(self)
    end

  end

end