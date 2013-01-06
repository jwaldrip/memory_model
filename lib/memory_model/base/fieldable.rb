require 'active_support/concern'
require 'active_support/dependencies/autoload'
require 'securerandom'

module MemoryModel::Base::Fieldable
  extend ConcernedInheritance
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload
  autoload :FieldSet
  autoload :Field

  inherited do
    instance_variable_set :@fields, baseclass.fields
    field :id, readonly: true, default: -> { SecureRandom.uuid }, comparable: false
  end

  module ClassMethods

    def field(attr, options={ })
      fields.add(attr.to_sym, options)
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{attr}
          read_attribute :#{attr}
        end

        def #{attr}=(value)
          write_attribute :#{attr}, value
        end
      RUBY
    end

    def fields
      return nil if self == MemoryModel::Base
      @fields ||= FieldSet.new
    end

  end

  def fields
    self.class.fields
  end

end