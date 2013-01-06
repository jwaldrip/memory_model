require 'active_support/concern'

module MemoryModel::Base::Collectable
  extend ActiveSupport::Concern
  extend ConcernedInheritance

  inherited do
    instance_variable_set :@collection, baseclass.collection
  end

  module ClassMethods
    delegate :all, :find, :insert, :<<, :deleted, to: :collection
    delegate :first, :last, to: :all

    def collection
      return nil if self == MemoryModel::Base
      @collection ||= MemoryModel::Collection.new(self)
    end

  end

end