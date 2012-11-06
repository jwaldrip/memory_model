require "memory_model/version"
require "active_support/all"
require "active_model"

module MemoryModel
  extend ActiveSupport::Autoload

  autoload :Base

  mattr_accessor :tables
  self.tables = []

  def self.truncate!
    !tables.map(&:truncate!).include?(false)
  end

end
