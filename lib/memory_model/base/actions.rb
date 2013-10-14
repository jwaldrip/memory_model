require 'ice_nine'
require 'ice_nine/core_ext/object'

module MemoryModel::Base::Actions
  extend ActiveSupport::Concern

  included do
    define_model_callbacks :create, :update, :save, :destroy
    attr_reader :timestamp
  end

  VALID_IVARS = [
    :@deleted,
    :@attributes,
    :@timestamp,
    :@version
  ]

  def commit
    @timestamp = Time.now
    @version   = SecureRandom.hex(6)
    self.class.insert self
    self
  end

  def delete
    @deleted = true
    commit
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

  def dup
    deep_dup
  end

  def deep_dup
    Marshal.load Marshal.dump self
  end

  def freeze
    instance_variables.reject { |ivar| ivar.in? VALID_IVARS }.each do |ivar|
      remove_instance_variable ivar if instance_variable_defined?(ivar)
    end
    instance_variables.each { |ivar| instance_variable_get(ivar).freeze }
    deep_freeze
    super
  end

  def save
    callback = persisted? ? :update : :create
    run_callbacks callback do
      run_callbacks :save do
        commit
      end
    end
  end

  def restore
    instance = frozen? ? self.dup : self
    instance.instance_variable_set :@deleted, false
    instance.save
    instance
  end

  module ClassMethods

    def create(attributes={})
      new(attributes).save
    end

    def delete_all
      all.map(&:delete).reject(&:deleted?).empty?
    end

    def destroy_all
      all.map(&:destroy).reject(&:deleted?).empty?
    end

  end

end