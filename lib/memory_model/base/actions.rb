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
      attr_reader :timestamp, :__sid__
      before_save(:remove_invalid_instance_vars)
    end

    VALID_IVARS = [
      :@attributes,
      :@timestamp,
      :@__sid__
    ]

    def delete
      self.class.collection.remove(self)
      freeze
    end

    def deleted?
      !!@deleted
    end

    def deleted_at
      deleted? ? @timestamp : nil
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
      callback = persisted? ? :update : :create
      run_callbacks callback do
        run_callbacks :save do
          @timestamp = Time.now
          @__sid__   ||= SecureRandom.uuid
          self.class.insert self
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