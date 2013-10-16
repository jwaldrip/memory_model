class MemoryModel::Collection::Index < Hash
  extend ActiveSupport::Autoload

  autoload :UniqueIndexMethods
  autoload :MultiIndexMethods
  autoload :AllowNilMethods

  attr_reader :name

  def initialize(name, options={})
    @name = name
    extend options.delete(:unique) ? UniqueIndexMethods : MultiIndexMethods
    options.each do |key, bool|
      const = case key
              when String, Symbol
                self.class.const_get key.to_s.camelize + 'Methods'
              when Module
                key
              end
      extend const if bool
    end
    super()
  end

  def valid_object?(*args)
    raise NotImplementedError, "#{__method__} has not been implemented for this #{name} index"
  end

  def insert(*args)
    raise NotImplementedError, "#{__method__} has not been implemented for this #{name} index"
  end

  def remove(*args)
    raise NotImplementedError, "#{__method__} has not been implemented for this #{name} index"
  end

  def where(*args)
    raise NotImplementedError, "#{__method__} has not been implemented for the #{name} index"
  end

end

