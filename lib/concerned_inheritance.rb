require 'active_support/concern'
require 'active_support/core_ext/class/attribute'
require 'active_support/dependencies/autoload'

module ConcernedInheritance
  extend ActiveSupport::Autoload

  autoload :Delegator
  autoload :ClassMethods
  autoload :ModuleMethods

  def self.extended(base)
    case base
    when Class
      base.extend ClassMethods
    when Module
      base.extend ModuleMethods
    end
    base.instance_variable_set :@inherited_callbacks, [] unless base.instance_variable_defined? :@inherited_callbacks
  end

  def define_inherited_callback(&block)
    raise ArgumentError, 'missing required block' unless block_given?
    @inherited_callbacks += [block]
  end

end