require "concerned_inheritance"
require 'active_support/core_ext/object'
require 'active_support/core_ext/hash'
require 'active_support/dependencies/autoload'
require 'active_support/core_ext/hash/indifferent_access'

class MemoryModel::Base
  extend ActiveSupport::Autoload
  extend ConcernedInheritance

  autoload :Fieldable
  autoload :Collectable
  autoload :Comparable
  autoload :Actionable
  autoload :Attributable
  autoload :Versionable

  include Fieldable
  include Collectable
  include Comparable
  include Actionable
  include Attributable
  include Versionable

  def initialize(attributes={ })
    unless self.class.collection.is_a? MemoryModel::Collection
      raise MemoryModel::InvalidCollectionError, "#{self.class} does not have an assigned collection"
    end
    @attributes = fields.default_values(self, attributes).with_indifferent_access
    @deleted    = false
  end

end