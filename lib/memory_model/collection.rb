require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/hash_with_indifferent_access'
require 'active_support/dependencies/autoload'

module MemoryModel
  class Collection
    extend ActiveSupport::Autoload

    autoload :Index
    autoload :MarshaledRecord
    autoload :LoaderDelegate
    autoload :Initializers
    autoload :Finders
    autoload :Operations

    attr_reader :primary_key

    include Finders
    include Initializers
    include Operations

    delegate *(LoaderDelegate.public_instance_methods - self.instance_methods), :size, :length, :inspect, to: :all

  end
end
