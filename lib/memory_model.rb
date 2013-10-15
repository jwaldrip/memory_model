require "memory_model/version"
require "active_support/dependencies/autoload"

module MemoryModel
  extend ActiveSupport::Autoload

  autoload :Collection
  autoload :Base

  class InvalidCollectionError < StandardError ; end
  class InvalidFieldError < StandardError ; end
  class ReadonlyFieldError < StandardError ; end
  class RecordNotFoundError < StandardError ; end

end
