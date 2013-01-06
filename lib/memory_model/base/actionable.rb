require 'ice_nine'
require 'ice_nine/core_ext/object'

module MemoryModel::Base::Actionable
  extend ActiveSupport::Concern

  included do
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

  def dup
    deep_dup
  end

  def deep_dup
    Marshal.load Marshal.dump self
  rescue # this is to handle anonymous classes
    temp_class_id = [:TEMP, self.class.object_id.to_s(36)].join('_')
    MemoryModel::Base.const_set temp_class_id, self.class
    deep_dup
  end

  def freeze
    instance_variables.reject { |ivar| ivar.in? VALID_IVARS }.each do |ivar|
      remove_instance_variable ivar if instance_variable_defined?(ivar)
    end
    instance_variables.each { |ivar| instance_variable_get(ivar).freeze }
    deep_freeze
    super
  end

  def restore
    instance = frozen? ? self.dup : self
    instance.instance_variable_set :@deleted, false
    instance.commit
    instance
  end

end