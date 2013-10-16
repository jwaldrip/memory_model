module MemoryModel

  class RecordInvalid < MemoryModel::Error
    attr_reader :record # :nodoc:
    def initialize(record) # :nodoc:
      @record = record
      errors  = @record.errors.full_messages.join(", ")
      super(errors)
    end
  end

  module Base::Actions
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload

    autoload :ClassMethods

    included do
      define_model_callbacks :create, :update, :save, :destroy, :validation
      define_model_callbacks :commit, only: :after
      before_save(:remove_invalid_instance_vars)
    end

    VALID_IVARS = [
      :@attributes
    ]

    def delete
      self.class.collection.delete(self)
      freeze
    end

    def destroy
      run_callbacks :destroy do
        delete
      end
    end

    def save(options={})
      !!perform_validations(options) ? commit : false
    end

    def save!(options={})
      !!perform_validations(options) ? commit : raise(RecordInvalid.new(self))
    end

    private

    def commit
      operation = persisted? ? :update : :create
      run_callbacks operation do
        run_callbacks :save do
          self.class.collection.send(operation, self)
          run_callbacks :commit
        end
      end
      self
    end

    def remove_invalid_instance_vars
      instance_variables.reject { |ivar| ivar.in? VALID_IVARS }.each do |ivar|
        remove_instance_variable ivar if instance_variable_defined?(ivar)
      end
    end

    def perform_validations(options={})
      run_callbacks :validation do
        options[:validate] == false || valid?(options[:context])
      end
    end

  end
end