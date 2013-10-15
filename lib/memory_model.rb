require "memory_model/version"
require "active_support/dependencies/autoload"

module MemoryModel
  extend ActiveSupport::Autoload

  autoload :Collection
  autoload :Base

  class Error < StandardError ; end
  class InvalidCollectionError < Error ; end
  class InvalidFieldError < Error ; end
  class ReadonlyFieldError < Error ; end
  class RecordNotFoundError < Error ; end

end
