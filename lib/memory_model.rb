require "memory_model/version"
require "active_support/dependencies/autoload"

module MemoryModel
  extend ActiveSupport::Autoload

  autoload :Collection
  autoload :Base

  class Error < StandardError ; end
  class ReadonlyFieldError < Error ; end

end
