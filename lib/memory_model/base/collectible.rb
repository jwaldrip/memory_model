require 'active_support/concern'
require 'active_support/core_ext/module/delegation'

module MemoryModel
  class Base
    module Collectible
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
  end
end