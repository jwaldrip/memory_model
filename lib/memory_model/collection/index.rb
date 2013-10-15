class MemoryModel::Collection::Index < Hash

  attr_reader :name

  def initialize(name)
    @name = name
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

