require "memory_model/version"
require "memory_model/core_ext/object"

module MemoryModel
  autoload :Collection, 'memory_model/collection'
  autoload :Base, 'memory_model/base'

  class InvalidCollectionError < StandardError ; end
  class InvalidFieldError < StandardError ; end
  class ReadonlyFieldError < StandardError ; end
  class RecordNotFoundError < StandardError ; end

end
