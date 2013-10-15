require 'ice_nine'
require 'ice_nine/core_ext/object'

module MemoryModel::Base::Actions
  extend ActiveSupport::Concern

  included do
    define_model_callbacks :create, :update, :save, :destroy
    attr_reader :timestamp, :sha
    before_save(:remove_invalid_instance_vars)
  end

  VALID_IVARS = [
    :@attributes,
    :@timestamp,
    :@sha
  ]

  def commit
    @timestamp = Time.now
    @sha = Digest::SHA256.hexdigest [@timestamp, object_id].join
    self.class.insert self
    self
  end

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

  def save
    callback = persisted? ? :update : :create
    run_callbacks callback do
      run_callbacks :save do
        commit
      end
    end
  end

  private

  def remove_invalid_instance_vars
    instance_variables.reject { |ivar| ivar.in? VALID_IVARS }.each do |ivar|
      remove_instance_variable ivar if instance_variable_defined?(ivar)
    end
  end

  module ClassMethods

    def create(attributes={})
      new(attributes).save
    end

    def delete_all
      count.tap do
        self.collection.clear
      end
    end

    def destroy_all
      self.all.each(&:destroy)
    end

  end

end