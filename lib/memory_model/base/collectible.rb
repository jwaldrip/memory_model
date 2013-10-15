require 'active_support/concern'

module MemoryModel::Base::Collectible
  extend ActiveSupport::Concern
  extend ConcernedInheritance

  inherited do
    instance_variable_set :@collection, baseclass.collection
  end

  module ClassMethods
    delegate *(MemoryModel::Collection.instance_methods - Object.instance_methods), to: :collection
    delegate :first, :last, to: :all

    def collection
      return nil if self == MemoryModel::Base
      @collection ||= MemoryModel::Collection.new(self)
    end

  end

end