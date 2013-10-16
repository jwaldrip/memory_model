require 'concerned_inheritance'
require 'active_support/core_ext/object'
require 'active_support/core_ext/hash'
require 'active_support/dependencies/autoload'
require 'active_model'

class MemoryModel::Base
  extend ActiveSupport::Autoload
  extend ConcernedInheritance

  autoload :Fields
  autoload :Collectible
  autoload :Comparison
  autoload :Actions
  autoload :Attributes
  autoload :Persistence
  autoload :Operations
  autoload :Conversion
  autoload :AutoIncrement

  # Active Model Additions
  extend ActiveModel::Callbacks
  extend ActiveModel::Naming
  extend ActiveModel::Translation
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  include ActiveModel::Validations

  # 3.2 Only Active Model Additions
  if ActiveModel::VERSION::MAJOR < 4 || (ActiveModel::VERSION::MAJOR == 3 && ActiveModel::VERSION::MINOR > 2)
    include ActiveModel::MassAssignmentSecurity
    include ActiveModel::Observing
  end

  # Memory Model Additions
  include Fields
  include Collectible
  include Operations::Comparisons
  include Actions
  include Attributes
  include Persistence
  include Conversion
  include AutoIncrement

  # Active Model Callbacks
  define_model_callbacks :initialize, only: [:after]

  def initialize(attributes={ })
    unless self.class.collection.is_a? MemoryModel::Collection
      raise MemoryModel::InvalidCollectionError, "#{self.class} does not have an assigned collection"
    end
    fields.set_default_values(self, attributes)
    run_callbacks :initialize
  end

  def initialize_dup(other)
    self.attributes = other.attributes
    @__side
    reset_incremented_fields!
    super
  end

end